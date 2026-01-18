import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class GeminiService {
  GenerativeModel? _model;
  GenerativeModel? _visionModel;
  bool _isInitialized = false;
  String? _initError;
  late String _apiKey;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    try {
      _apiKey = AppConfig.getGeminiApiKey();
      if (_apiKey.isEmpty) {
        _initError = 'Gemini API key not configured';
        debugPrint('Warning: $_initError');
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
      _visionModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
      _isInitialized = true;
      _initError = null;
      debugPrint('Gemini service initialized successfully with Imagen 3');
    } catch (e) {
      _initError = e.toString();
      debugPrint('Failed to initialize Gemini: $e');
    }
  }

  bool get isConfigured => _isInitialized;
  String? get initializationError => _initError;

  /// Reinitialize the service (useful after config changes)
  void reinitialize() {
    _isInitialized = false;
    _model = null;
    _visionModel = null;
    _initialize();
  }

  /// Generate an image using Imagen 3 API
  /// This creates a virtual try-on image by generating what the person would look like wearing the clothing
  Future<Map<String, dynamic>> generateTryOnWithImagen({
    required Uint8List userPhoto,
    required String clothingDescription,
    Uint8List? clothingImage,
  }) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'error': 'AI service not configured',
        'generatedImageBytes': null,
      };
    }

    try {
      // First, analyze the user photo to get a description for better image generation
      String userDescription = await _analyzeUserForImageGen(userPhoto);

      // Create a detailed prompt for virtual try-on
      final prompt =
          '''
Create a photorealistic fashion photograph of a person wearing $clothingDescription.
The person should match this description: $userDescription
Style: Professional fashion photography, full body shot, clean background, natural lighting.
The clothing should fit naturally and look realistic on the person.
High quality, detailed, fashion magazine style.
''';

      debugPrint('Generating image with Imagen 3...');

      // Use REST API for Imagen 3
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key=$_apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'instances': [
                {'prompt': prompt},
              ],
              'parameters': {
                'sampleCount': 1,
                'aspectRatio': '3:4',
                'safetyFilterLevel': 'block_few',
                'personGeneration': 'allow_adult',
              },
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          final imageBase64 = data['predictions'][0]['bytesBase64Encoded'];
          if (imageBase64 != null) {
            final imageBytes = base64Decode(imageBase64);
            debugPrint('Image generated successfully');
            return {
              'success': true,
              'generatedImageBytes': imageBytes,
              'prompt': prompt,
            };
          }
        }
      }

      // If Imagen fails, try with Gemini 2.0 Flash which has native image generation
      debugPrint('Imagen 3 failed, trying Gemini native image generation...');
      return await _generateWithGeminiNative(
        prompt,
        userPhoto,
        clothingDescription,
      );
    } catch (e) {
      debugPrint('Imagen generation error: $e');
      // Fallback to Gemini native
      return await _generateWithGeminiNative(
        'A person wearing $clothingDescription, fashion photography style',
        userPhoto,
        clothingDescription,
      );
    }
  }

  /// Analyze user photo to get description for image generation
  Future<String> _analyzeUserForImageGen(Uint8List userPhoto) async {
    if (_visionModel == null) {
      return 'a stylish person';
    }

    try {
      final prompt = '''
Describe this person briefly for an AI image generator. Include:
- Approximate age range
- Gender presentation
- Skin tone
- Hair color and style
- Body type
Keep it to 2-3 sentences, factual and respectful.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', userPhoto)]),
      ];

      final response = await _visionModel!
          .generateContent(content)
          .timeout(const Duration(seconds: 15));

      return response.text ?? 'a stylish person';
    } catch (e) {
      debugPrint('User analysis error: $e');
      return 'a stylish person';
    }
  }

  /// Generate image using Gemini 2.0 Flash with native image generation
  Future<Map<String, dynamic>> _generateWithGeminiNative(
    String prompt,
    Uint8List userPhoto,
    String clothingDescription,
  ) async {
    try {
      // Try Gemini 2.0 Flash experimental with image generation
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$_apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'contents': [
                {
                  'parts': [
                    {'text': 'Generate an image of: $prompt'},
                  ],
                },
              ],
              'generationConfig': {
                'responseModalities': ['TEXT', 'IMAGE'],
              },
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'];
          for (var part in parts) {
            if (part['inlineData'] != null) {
              final imageData = part['inlineData']['data'];
              if (imageData != null) {
                return {
                  'success': true,
                  'generatedImageBytes': base64Decode(imageData),
                  'prompt': prompt,
                };
              }
            }
          }
        }
      }

      debugPrint(
        'Gemini native image generation response: ${response.statusCode}',
      );

      // If image generation fails, return analysis-only result
      return {
        'success': false,
        'error': 'Image generation not available. Using text analysis instead.',
        'generatedImageBytes': null,
      };
    } catch (e) {
      debugPrint('Gemini native generation error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'generatedImageBytes': null,
      };
    }
  }

  /// Generate AI outfit recommendations based on wardrobe items and occasion
  Future<List<Map<String, dynamic>>> generateOutfitRecommendations({
    required List<Map<String, dynamic>> wardrobeItems,
    required String occasion,
    String? stylePreferences,
  }) async {
    if (!_isInitialized || _model == null) {
      debugPrint('Gemini not initialized, using fallback recommendations');
      return _generateFallbackRecommendations(wardrobeItems, occasion);
    }

    if (wardrobeItems.isEmpty) {
      return [
        {
          'title': 'Add Items First',
          'items': ['Please add clothing items to your wardrobe'],
          'tip':
              'Upload photos of your clothes to get personalized AI recommendations.',
        },
      ];
    }

    try {
      final itemDescriptions = wardrobeItems
          .map((item) {
            return '${item['name']} (${item['category']}, ${item['color']})';
          })
          .join(', ');

      final prompt =
          '''
You are a professional fashion stylist AI. Based on the following wardrobe items and occasion, create 3 unique, stylish outfit recommendations.

Available Wardrobe Items: $itemDescriptions

Occasion: $occasion
${stylePreferences != null ? 'Style Preferences: $stylePreferences' : ''}

IMPORTANT RULES:
1. Only use items from the provided wardrobe list - do not suggest items that aren't listed
2. Each outfit should have 2-4 items that work well together
3. Consider color coordination and style cohesion
4. Make the outfit appropriate for the specified occasion

For each outfit, provide:
1. A creative, catchy outfit title
2. A list of 2-4 specific items from the wardrobe (use exact names provided)
3. A practical styling tip

You MUST respond with valid JSON only, no other text:
{
  "outfits": [
    {
      "title": "Creative Outfit Title",
      "items": ["exact item name 1", "exact item name 2", "exact item name 3"],
      "tip": "Specific styling tip for this outfit"
    },
    {
      "title": "Second Outfit Title",
      "items": ["item name", "item name"],
      "tip": "Styling tip"
    },
    {
      "title": "Third Outfit Title",
      "items": ["item name", "item name", "item name"],
      "tip": "Styling tip"
    }
  ]
}
''';

      debugPrint('Sending recommendation request to Gemini...');
      final content = [Content.text(prompt)];
      final response = await _model!
          .generateContent(content)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.text != null && response.text!.isNotEmpty) {
        debugPrint('Received response from Gemini');
        try {
          final jsonStr = _extractJson(response.text!);
          final parsed = json.decode(jsonStr);

          if (parsed is Map && parsed.containsKey('outfits')) {
            final outfits = List<Map<String, dynamic>>.from(
              (parsed['outfits'] as List).map(
                (e) => Map<String, dynamic>.from(e),
              ),
            );
            debugPrint('Successfully parsed ${outfits.length} outfits');
            return outfits;
          }
        } catch (parseError) {
          debugPrint('JSON parse error: $parseError');
          debugPrint('Raw response: ${response.text}');
        }
      }

      debugPrint('Invalid response, using fallback');
      return _generateFallbackRecommendations(wardrobeItems, occasion);
    } catch (e) {
      debugPrint('Gemini recommendation error: $e');
      return _generateFallbackRecommendations(wardrobeItems, occasion);
    }
  }

  /// Generate virtual try-on with AI image generation and analysis
  Future<Map<String, dynamic>> generateTryOnImage({
    required Uint8List userPhoto,
    required String clothingDescription,
    String? clothingImageUrl,
  }) async {
    if (!_isInitialized || _visionModel == null) {
      return {
        'success': false,
        'description':
            'AI service not configured. Please check your Gemini API key in settings.',
        'status': 'failed',
      };
    }

    try {
      // If we have a clothing image URL, fetch it
      Uint8List? clothingImageBytes;
      if (clothingImageUrl != null && clothingImageUrl.isNotEmpty) {
        try {
          final response = await http
              .get(Uri.parse(clothingImageUrl))
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            clothingImageBytes = response.bodyBytes;
          }
        } catch (e) {
          debugPrint('Failed to fetch clothing image: $e');
        }
      }

      // Try to generate an actual image using Imagen 3
      debugPrint('Attempting AI image generation for try-on...');
      final imageGenResult = await generateTryOnWithImagen(
        userPhoto: userPhoto,
        clothingDescription: clothingDescription,
        clothingImage: clothingImageBytes,
      );

      // Now generate the text analysis
      final prompt =
          '''
You are an expert fashion stylist and virtual try-on assistant. Analyze this photo of a person and provide a detailed virtual try-on assessment for: $clothingDescription

Please provide a comprehensive analysis including:

1. **VISUALIZATION**: Describe in vivid detail how this person would look wearing the $clothingDescription. Paint a mental picture of the complete look.

2. **FIT ASSESSMENT**: Based on the person's visible body type and proportions, assess how the clothing would fit:
   - Would it be flattering?
   - Are there any fit considerations?
   - What size might work best?

3. **COLOR HARMONY**: Analyze how the clothing colors would complement:
   - The person's skin tone
   - Their hair color
   - Overall color coordination

4. **STYLING SUGGESTIONS**: Provide 3-4 specific tips to make this outfit look amazing:
   - Accessories to add
   - How to style the outfit
   - What to pair it with

5. **OCCASIONS**: List 2-3 occasions where this outfit would be perfect.

6. **CONFIDENCE RATING**: Rate from 1-10 how well this outfit would suit this person, with explanation.

Be encouraging, specific, and provide actionable fashion advice!
''';

      final List<Part> parts = [TextPart(prompt)];
      parts.add(DataPart('image/jpeg', userPhoto));

      if (clothingImageBytes != null) {
        parts.add(DataPart('image/jpeg', clothingImageBytes));
      }

      final content = [Content.multi(parts)];
      final response = await _visionModel!
          .generateContent(content)
          .timeout(const Duration(seconds: 45));

      if (response.text != null && response.text!.isNotEmpty) {
        final analysis = _parseStyleAnalysis(response.text!);

        return {
          'success': true,
          'description': response.text,
          'analysis': analysis,
          'status': 'completed',
          'hasGeneratedImage': imageGenResult['success'] == true,
          'generatedImageBytes': imageGenResult['generatedImageBytes'],
        };
      }

      return {
        'success': true,
        'description':
            'This outfit would look great on you! The $clothingDescription complements your style beautifully.',
        'status': 'completed',
        'hasGeneratedImage': imageGenResult['success'] == true,
        'generatedImageBytes': imageGenResult['generatedImageBytes'],
      };
    } catch (e) {
      debugPrint('Gemini try-on error: $e');
      return {
        'success': false,
        'description':
            'Unable to generate try-on preview. Please try again later.',
        'status': 'failed',
      };
    }
  }

  /// Generate a complete outfit visualization combining user photo with clothing
  Future<Map<String, dynamic>> generateOutfitVisualization({
    required Uint8List userPhoto,
    required List<Map<String, dynamic>> selectedItems,
  }) async {
    if (!_isInitialized || _visionModel == null) {
      return {
        'success': false,
        'description': 'AI service not configured.',
        'status': 'failed',
      };
    }

    try {
      final itemsDescription = selectedItems
          .map((item) {
            return '${item['name']} (${item['category']}, ${item['color']})';
          })
          .join(', ');

      final prompt =
          '''
You are an expert fashion stylist. Analyze this photo and create a detailed visualization of how this person would look wearing the following outfit:

OUTFIT ITEMS: $itemsDescription

Provide:

1. **COMPLETE LOOK DESCRIPTION**: Describe the full outfit from head to toe, including how each piece works together.

2. **STYLE ASSESSMENT**:
   - Overall aesthetic (casual, formal, trendy, etc.)
   - How the colors coordinate
   - The mood/vibe of the look

3. **PERSONALIZED FIT**: How would each item fit and look on this specific person?

4. **ENHANCEMENT TIPS**: 3 ways to elevate this outfit further.

5. **ALTERNATIVE STYLING**: One alternative way to style these same pieces.

Be detailed, encouraging, and help the person visualize exactly how amazing they'll look!
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', userPhoto)]),
      ];

      final response = await _visionModel!
          .generateContent(content)
          .timeout(const Duration(seconds: 45));

      return {
        'success': true,
        'description':
            response.text ??
            'This outfit combination would look fantastic on you!',
        'items': selectedItems.map((i) => i['name']).toList(),
        'status': 'completed',
      };
    } catch (e) {
      debugPrint('Gemini visualization error: $e');
      return {
        'success': false,
        'description': 'Unable to generate visualization. Please try again.',
        'status': 'failed',
      };
    }
  }

  /// Analyze wardrobe and provide style insights
  Future<Map<String, dynamic>> analyzeWardrobe({
    required List<Map<String, dynamic>> wardrobeItems,
  }) async {
    if (!_isInitialized || _model == null) {
      return _getDefaultAnalysis();
    }

    try {
      final itemDescriptions = wardrobeItems
          .map((item) {
            return '${item['name']} (${item['category']}, ${item['color']})';
          })
          .join('\n');

      final prompt =
          '''
Analyze this wardrobe and provide fashion insights:

Wardrobe Items:
$itemDescriptions

Respond with valid JSON only:
{
  "styleProfile": "Description of the person's style",
  "dominantColors": ["color1", "color2", "color3"],
  "missingEssentials": ["item1", "item2"],
  "versatilityScore": 85,
  "recommendations": ["tip1", "tip2", "tip3"]
}
''';

      final content = [Content.text(prompt)];
      final response = await _model!
          .generateContent(content)
          .timeout(const Duration(seconds: 30));

      if (response.text != null) {
        final jsonStr = _extractJson(response.text!);
        return json.decode(jsonStr);
      }

      return _getDefaultAnalysis();
    } catch (e) {
      debugPrint('Gemini analysis error: $e');
      return _getDefaultAnalysis();
    }
  }

  /// Get personalized style quiz analysis
  Future<Map<String, dynamic>> analyzeStyleQuiz({
    required Map<String, String> answers,
  }) async {
    if (!_isInitialized || _model == null) {
      return _getDefaultStyleProfile();
    }

    try {
      final prompt =
          '''
Based on these style quiz answers, determine the person's fashion personality:

${answers.entries.map((e) => '${e.key}: ${e.value}').join('\n')}

Respond with valid JSON only:
{
  "stylePersonality": "Style type name",
  "description": "Brief description of their style",
  "colorPalette": ["color1", "color2", "color3", "color4"],
  "recommendedBrands": ["brand1", "brand2", "brand3"],
  "keyPieces": ["piece1", "piece2", "piece3"],
  "styleIcons": ["celebrity1", "celebrity2"]
}
''';

      final content = [Content.text(prompt)];
      final response = await _model!
          .generateContent(content)
          .timeout(const Duration(seconds: 30));

      if (response.text != null) {
        final jsonStr = _extractJson(response.text!);
        return json.decode(jsonStr);
      }

      return _getDefaultStyleProfile();
    } catch (e) {
      debugPrint('Gemini quiz analysis error: $e');
      return _getDefaultStyleProfile();
    }
  }

  /// Analyze clothing item from image
  Future<Map<String, dynamic>> analyzeClothingItem({
    required Uint8List imageBytes,
  }) async {
    if (!_isInitialized || _visionModel == null) {
      return {
        'success': false,
        'category': 'Tops',
        'color': 'Neutral',
        'suggestedName': 'Clothing Item',
      };
    }

    try {
      final prompt = '''
Analyze this clothing item image and provide details.

Respond with valid JSON only:
{
  "category": "One of: Tops, Bottoms, Dresses, Shoes, Outerwear, Accessories",
  "color": "One of: Neutral, Warm, Cool, Bright, Pastel, Dark",
  "suggestedName": "A descriptive name for this item",
  "material": "Fabric/material type",
  "style": "Style description (casual, formal, sporty, etc.)",
  "occasions": ["occasion1", "occasion2"]
}
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _visionModel!
          .generateContent(content)
          .timeout(const Duration(seconds: 30));

      if (response.text != null) {
        final jsonStr = _extractJson(response.text!);
        final result = json.decode(jsonStr);
        return {'success': true, ...result};
      }

      return {
        'success': false,
        'category': 'Tops',
        'color': 'Neutral',
        'suggestedName': 'Clothing Item',
      };
    } catch (e) {
      debugPrint('Gemini clothing analysis error: $e');
      return {
        'success': false,
        'category': 'Tops',
        'color': 'Neutral',
        'suggestedName': 'Clothing Item',
      };
    }
  }

  /// Parse style analysis from response text
  Map<String, dynamic> _parseStyleAnalysis(String text) {
    int? confidenceRating;
    final ratingMatch = RegExp(
      r'(\d+)/10|rating[:\s]+(\d+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (ratingMatch != null) {
      confidenceRating = int.tryParse(
        ratingMatch.group(1) ?? ratingMatch.group(2) ?? '',
      );
    }

    return {
      'confidenceRating': confidenceRating ?? 8,
      'hasVisualization':
          text.toLowerCase().contains('visualization') ||
          text.toLowerCase().contains('would look'),
      'hasFitAssessment': text.toLowerCase().contains('fit'),
      'hasColorAnalysis': text.toLowerCase().contains('color'),
      'hasStylingTips':
          text.toLowerCase().contains('tip') ||
          text.toLowerCase().contains('suggestion'),
    };
  }

  /// Extract JSON from potentially markdown-wrapped response
  String _extractJson(String text) {
    // Remove markdown code blocks if present
    var cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```JSON', '')
        .replaceAll('```', '')
        .trim();

    // Find the first { and last }
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start != -1 && end != -1 && end > start) {
      return cleaned.substring(start, end + 1);
    }

    return cleaned;
  }

  List<Map<String, dynamic>> _generateFallbackRecommendations(
    List<Map<String, dynamic>> items,
    String occasion,
  ) {
    final itemNames = items.map((i) => i['name'] as String? ?? 'Item').toList();
    if (itemNames.isEmpty) {
      return [
        {
          'title': 'Add Items First',
          'items': ['Please add clothing items to your wardrobe'],
          'tip':
              'Upload photos of your clothes to get personalized recommendations.',
        },
      ];
    }

    // Group items by category for smarter fallback
    final tops = items
        .where((i) => i['category'] == 'Tops')
        .map((i) => i['name'] as String)
        .toList();
    final bottoms = items
        .where((i) => i['category'] == 'Bottoms')
        .map((i) => i['name'] as String)
        .toList();
    final shoes = items
        .where((i) => i['category'] == 'Shoes')
        .map((i) => i['name'] as String)
        .toList();
    final outerwear = items
        .where((i) => i['category'] == 'Outerwear')
        .map((i) => i['name'] as String)
        .toList();
    final accessories = items
        .where((i) => i['category'] == 'Accessories')
        .map((i) => i['name'] as String)
        .toList();

    List<Map<String, dynamic>> outfits = [];

    // Create smart outfit combinations
    if (tops.isNotEmpty && bottoms.isNotEmpty) {
      outfits.add({
        'title': 'Classic $occasion Look',
        'items': [tops.first, bottoms.first, if (shoes.isNotEmpty) shoes.first],
        'tip': 'A timeless combination that works for any $occasion setting.',
      });
    }

    if (tops.length > 1 || bottoms.length > 1) {
      outfits.add({
        'title': 'Modern $occasion Style',
        'items': [
          tops.length > 1 ? tops[1] : tops.firstOrNull ?? itemNames.first,
          bottoms.length > 1
              ? bottoms[1]
              : bottoms.firstOrNull ??
                    itemNames.skip(1).firstOrNull ??
                    itemNames.first,
          if (accessories.isNotEmpty) accessories.first,
        ],
        'tip': 'Add a statement accessory to elevate this look.',
      });
    }

    if (outerwear.isNotEmpty && tops.isNotEmpty) {
      outfits.add({
        'title': 'Layered $occasion Ensemble',
        'items': [
          outerwear.first,
          tops.first,
          if (bottoms.isNotEmpty) bottoms.first,
        ],
        'tip': 'Perfect for variable weather - layer up or down as needed.',
      });
    }

    // Ensure we have at least 3 outfits
    while (outfits.length < 3) {
      outfits.add({
        'title': 'Effortless $occasion Vibe',
        'items': itemNames.take(3).toList(),
        'tip': 'Confidence is your best accessory!',
      });
    }

    return outfits.take(3).toList();
  }

  Map<String, dynamic> _getDefaultAnalysis() {
    return {
      'styleProfile': 'Versatile & Modern',
      'dominantColors': ['Black', 'White', 'Blue'],
      'missingEssentials': ['Statement piece', 'Neutral blazer'],
      'versatilityScore': 75,
      'recommendations': [
        'Add more accent colors',
        'Invest in quality basics',
        'Try mixing casual and formal pieces',
      ],
    };
  }

  Map<String, dynamic> _getDefaultStyleProfile() {
    return {
      'stylePersonality': 'Contemporary Classic',
      'description': 'You appreciate timeless pieces with a modern twist.',
      'colorPalette': ['Navy', 'White', 'Camel', 'Black'],
      'recommendedBrands': ['Zara', 'COS', 'Massimo Dutti'],
      'keyPieces': ['Tailored blazer', 'White sneakers', 'Quality denim'],
      'styleIcons': ['David Beckham', 'Olivia Palermo'],
    };
  }
}
