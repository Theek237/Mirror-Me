import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:mm/core/errors/exception.dart';
import 'package:mm/core/constants/gemini_config.dart';

abstract class GeminiRemoteDataSource {
  /// Generates a virtual try-on image using Gemini Image Generation API
  Future<Uint8List> generateTryOnImage({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  });
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final String apiKey;
  final Dio _dio;

  GeminiRemoteDataSourceImpl({required this.apiKey})
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

  @override
  Future<Uint8List> generateTryOnImage({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  }) async {
    try {
      final prompt =
          customPrompt ??
          '''You are a professional AI virtual try-on engine specialized in photorealistic garment transfer and fashion visualization.

OBJECTIVE:
Generate ONE ultra-photorealistic image of the person in the POSE IMAGE wearing the garment from the CLOTHING IMAGE.

INPUTS:
- POSE IMAGE: Contains the person, pose, body proportions, lighting, and background.
- CLOTHING IMAGE: Contains the target garment to be applied.

STRICT EXECUTION RULES:

IDENTITY & BODY PRESERVATION:
- Preserve the exact face, hairstyle, expression, skin tone, and body proportions of the person.
- Do NOT modify body shape, weight, height, muscle tone, or facial features.
- Do NOT beautify, stylize, or alter identity in any way.

POSE & SCENE PRESERVATION:
- Maintain 100% of the original pose.
- Keep the original background unchanged.
- Preserve camera angle, perspective, focal length, and framing.
- Maintain original lighting direction, intensity, shadows, and color temperature.

GARMENT TRANSFER RULES:
- Replace ONLY the relevant clothing region.
- Do NOT alter non-target clothing items.
- The garment must follow natural body contours.
- Apply realistic fabric physics: folds, tension, stretching, gravity, and compression.
- Respect fabric type (denim, cotton, silk, knit, etc.) and reflect its texture accordingly.
- Preserve garment details: logos, prints, stitching, buttons, zippers, seams.

FIT & ALIGNMENT:
- Ensure anatomically correct alignment at shoulders, sleeves, neckline, waist, and hips.
- Avoid floating fabric, clipping, distortion, or unnatural stretching.
- Ensure proper sleeve length, garment length, and proportional scaling.

REALISM ENFORCEMENT:
- Match lighting and shadows between body and garment.
- Add realistic shading, occlusion, and depth.
- Ensure natural wrinkles at joints (elbows, waist, underarms).
- Maintain consistent resolution and sharpness with the POSE IMAGE.
- No blur, no artifacts, no texture melting.

PROHIBITED OUTPUTS:
- No stylized, cartoon, painted, or AI-art look.
- No body reshaping.
- No background modification.
- No multiple outputs.
- No extra garments.
- No duplicated limbs or fabric glitches.

OUTPUT REQUIREMENT:
Generate exactly ONE high-resolution photorealistic image that looks like a real photograph taken of the person naturally wearing the garment.

The result must be indistinguishable from an authentic camera photograph.
''';

      // Convert images to base64
      final poseImageBase64 = base64Encode(poseImageBytes);
      final clothingImageBase64 = base64Encode(clothingImageBytes);

      // Build request body for Gemini API with image generation
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {'text': '\n\nPOSE IMAGE (the person to dress):'},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': poseImageBase64,
                },
              },
              {'text': '\n\nCLOTHING IMAGE (the item to wear):'},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': clothingImageBase64,
                },
              },
              {
                'text':
                    '\n\nNow generate the virtual try-on result showing the person wearing this clothing:',
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 1.0,
          'maxOutputTokens': 8192,
          'responseModalities': ['TEXT', 'IMAGE'],
        },
      };

      // Make API request
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/${GeminiConfig.imageModel}:generateContent?key=$apiKey',
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Extract image from response
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null &&
              candidate['content']['parts'] != null) {
            final parts = candidate['content']['parts'] as List;

            for (final part in parts) {
              // Check for inline_data (image response)
              if (part['inlineData'] != null) {
                final imageData = part['inlineData']['data'] as String;
                return base64Decode(imageData);
              }
            }

            // If no image, check for text response (error explanation)
            for (final part in parts) {
              if (part['text'] != null) {
                final textResponse = part['text'] as String;
                if (textResponse.isNotEmpty) {
                  throw ServerException(
                    message:
                        'AI could not generate image. Response: ${textResponse.substring(0, textResponse.length > 200 ? 200 : textResponse.length)}',
                  );
                }
              }
            }
          }
        }

        throw ServerException(
          message:
              'No image generated. Please try again with different images.',
        );
      } else {
        throw ServerException(
          message: 'API request failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['error'] != null) {
          errorMessage = errorData['error']['message'] ?? errorMessage;
        }
      }

      throw ServerException(message: 'AI generation failed: $errorMessage');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to generate try-on image: $e');
    }
  }
}
