import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/domain/entities/tryon_result.dart';

abstract class TryOnRepository {
  /// Generates a virtual try-on image using AI
  /// Takes pose image bytes, clothing image bytes, and optional custom prompt
  /// Returns Either a Failure or the generated image bytes
  Future<Either<Failure, Uint8List>> generateTryOn({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  });

  /// Saves a try-on result to the database
  Future<Either<Failure, TryOnResult>> saveTryOnResult({
    required String userId,
    required String poseImageUrl,
    required String clothingImageUrl,
    required Uint8List resultImageBytes,
    String? prompt,
  });

  /// Gets all try-on results for a user
  Future<Either<Failure, List<TryOnResult>>> getTryOnResults(String userId);

  /// Gets favorite try-on results for a user
  Future<Either<Failure, List<TryOnResult>>> getFavoriteTryOnResults(
    String userId,
  );

  /// Toggles favorite status for a try-on result
  Future<Either<Failure, TryOnResult>> toggleFavorite(
    String resultId,
    bool isFavorite,
  );

  /// Deletes a try-on result
  Future<Either<Failure, void>> deleteTryOnResult(String resultId);
}
