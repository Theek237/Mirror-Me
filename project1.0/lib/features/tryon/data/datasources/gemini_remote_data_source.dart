import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ServerException;
import 'package:mm/core/errors/exception.dart';
import 'package:mm/core/constants/gemini_config.dart';

abstract class GeminiRemoteDataSource {
  /// Generates a virtual try-on image using Gemini 3 Pro Image (Nano Banana Pro)
  Future<Uint8List> generateTryOnImage({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  });
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiRemoteDataSourceImpl({required this.apiKey}) {
    _model = GenerativeModel(
      model: GeminiConfig.imageModel, // Use model from config
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        maxOutputTokens: 8192,
      ),
    );
  }

  @override
  Future<Uint8List> generateTryOnImage({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  }) async {
    try {
      final prompt =
          customPrompt ??
          '''You are an expert AI fashion assistant specializing in virtual try-on technology.

TASK: Generate a photorealistic image showing the person from the first image (POSE IMAGE) wearing the clothing item from the second image (CLOTHING IMAGE).

IMPORTANT INSTRUCTIONS:
1. Preserve the exact pose, body position, background, and lighting from the POSE IMAGE
2. Replace ONLY the relevant clothing on the person with the clothing from the CLOTHING IMAGE
3. The clothing should fit naturally on the person's body
4. Maintain the original person's face, skin tone, and body proportions
5. Ensure the clothing looks realistic with proper shadows, wrinkles, and folds
6. Keep the same image quality and resolution as the original pose image

Generate ONE high-quality photorealistic result image.''';

      final content = [
        Content.multi([
          TextPart(prompt),
          TextPart('\n\nPOSE IMAGE (the person to dress):'),
          DataPart('image/jpeg', poseImageBytes),
          TextPart('\n\nCLOTHING IMAGE (the item to wear):'),
          DataPart('image/jpeg', clothingImageBytes),
          TextPart(
            '\n\nNow generate the virtual try-on result showing the person wearing this clothing:',
          ),
        ]),
      ];

      final response = await _model.generateContent(content);

      // Extract generated image from response
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        if (candidate.content.parts.isNotEmpty) {
          for (final part in candidate.content.parts) {
            if (part is DataPart) {
              // Found generated image
              return Uint8List.fromList(part.bytes);
            }
          }
        }
      }

      // If no image in response, check if it's a text response explaining why
      final textResponse = response.text;
      if (textResponse != null && textResponse.isNotEmpty) {
        throw ServerException(
          message:
              'AI could not generate image. Response: ${textResponse.substring(0, textResponse.length > 200 ? 200 : textResponse.length)}',
        );
      }

      throw ServerException(
        message: 'No image generated. Please try again with different images.',
      );
    } on GenerativeAIException catch (e) {
      throw ServerException(message: 'AI generation failed: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to generate try-on image: $e');
    }
  }
}
