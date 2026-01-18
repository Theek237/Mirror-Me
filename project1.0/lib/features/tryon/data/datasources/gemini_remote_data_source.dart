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
