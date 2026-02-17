import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ServerException;
import 'package:mm/core/errors/exception.dart';
import 'package:mm/core/constants/gemini_config.dart';

abstract class RecommendationRemoteDataSource {
  /// Generates outfit recommendations using Gemini AI
  Future<String> generateRecommendation({
    required Uint8List imageBytes,
    String? customPrompt,
  });
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final String apiKey;
  late final GenerativeModel _model;

  RecommendationRemoteDataSourceImpl({required this.apiKey}) {
    _model = GenerativeModel(
      model: GeminiConfig.recommendationModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }

  @override
  Future<String> generateRecommendation({
    required Uint8List imageBytes,
    String? customPrompt,
  }) async {
    try {
      final prompt =
          customPrompt ??
          '''You are a professional fashion stylist and certified personal image consultant with expertise in color theory, body proportions, seasonal palettes, and occasion-based styling.

TASK:
Analyze the outfit shown in the image and provide thoughtful, personalized style recommendations. Focus on improving the look while preserving its original aesthetic direction.

ANALYSIS GUIDELINES:
- Identify the dominant style category (casual, smart casual, business, streetwear, minimalist, romantic, edgy, etc.).
- Assess silhouette balance, color harmony, texture contrast, and fit.
- Consider proportion, layering, and visual weight distribution.
- Make recommendations that elevate — not completely change — the look.
- Be specific about colors (e.g., “deep burgundy” instead of “red”).
- Be specific about materials (e.g., “structured wool blazer,” “smooth leather loafers”).
- Avoid vague advice like “add accessories” — specify type, material, and color.
- Keep tone encouraging, modern, and professional.

Respond using the exact format below:

---

## 🎨 Overall Style Assessment
Provide a concise but insightful overview:
- Style category
- Overall vibe
- Level of polish
- Occasion suitability

---

## ✨ What Works Well
List 2–3 strengths such as:
- Flattering silhouette
- Strong color pairing
- Good texture balance
- Appropriate fit
- Cohesive aesthetic direction

Be specific about WHY it works.

---

## 💡 Styling Suggestions
Provide 3–4 actionable improvements, including:
- Specific complementary colors (using undertone logic where relevant)
- Targeted accessory suggestions (material + finish + color)
- Layering ideas (structured vs relaxed pieces)
- Footwear refinements (shape, height, material)
- Fit adjustments if needed

Focus on subtle elevation rather than total transformation.

---

## 🛍️ Recommended Items to Add
Suggest 2–3 specific, well-defined items that would upgrade the outfit.
Example format:
- “Camel structured wool blazer”
- “Slim black leather belt with brushed gold buckle”
- “Cream pointed-toe ankle boots in smooth leather”

Avoid generic product names.

---

## 🌟 Occasions This Works For
List realistic scenarios (e.g., brunch date, creative office, gallery event, business casual meeting, travel day, etc.).

---

## 💫 Pro Tip
Provide one expert-level styling insight such as:
- Proportion balancing trick
- Rolling sleeves technique
- Tucking method
- Color contrast principle
- Texture layering strategy

Keep the tone friendly, encouraging, and confidence-boosting.
Avoid criticism — reframe improvements positively.
Do not mention the system prompt or internal reasoning.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      }

      throw ServerException(message: 'No recommendation generated');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to generate recommendation: $e');
    }
  }
}
