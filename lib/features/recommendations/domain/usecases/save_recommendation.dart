import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/recommendations/domain/entities/recommendation.dart';
import 'package:mm/features/recommendations/domain/repositories/recommendation_repository.dart';

class SaveRecommendation {
  final RecommendationRepository repository;

  SaveRecommendation(this.repository);

  Future<Either<Failure, Recommendation>> call({
    required String userId,
    required String imageUrl,
    required String recommendationText,
    String? imageSource,
  }) {
    return repository.saveRecommendation(
      userId: userId,
      imageUrl: imageUrl,
      recommendationText: recommendationText,
      imageSource: imageSource,
    );
  }
}
