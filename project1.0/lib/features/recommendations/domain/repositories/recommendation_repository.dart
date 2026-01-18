import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/recommendations/domain/entities/recommendation.dart';

abstract class RecommendationRepository {
  /// Generates AI recommendations for an outfit image
  Future<Either<Failure, String>> generateRecommendation({
    required Uint8List imageBytes,
    String? customPrompt,
  });

  /// Saves a recommendation to the database
  Future<Either<Failure, Recommendation>> saveRecommendation({
    required String userId,
    required String imageUrl,
    required String recommendationText,
    String? imageSource,
  });

  /// Gets all recommendations for a user
  Future<Either<Failure, List<Recommendation>>> getRecommendations(
    String userId,
  );

  /// Deletes a recommendation
  Future<Either<Failure, void>> deleteRecommendation(String id);
}
