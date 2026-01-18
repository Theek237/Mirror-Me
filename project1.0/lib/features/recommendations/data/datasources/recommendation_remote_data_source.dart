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
          '''You are an expert fashion stylist and personal image consultant. Analyze the outfit in this image and provide comprehensive style recommendations.

Please provide your analysis in the following format:

## 🎨 Overall Style Assessment
[Brief assessment of the current outfit's style, vibe, and occasion suitability]

## ✨ What Works Well
[List 2-3 things that look great about this outfit]

## 💡 Styling Suggestions
[Provide 3-4 specific suggestions to enhance this look, including:
- Color combinations that would complement
- Accessory recommendations
- Layering ideas
- Footwear suggestions]

## 🛍️ Recommended Items to Add
[Suggest 2-3 specific items that would elevate this outfit]

## 🌟 Occasions This Works For
[List suitable occasions/events for this outfit]

## 💫 Pro Tip
[One insider styling tip related to this look]

Keep your tone friendly, encouraging, and helpful. Be specific with colors, materials, and styles when making recommendations.''';

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
