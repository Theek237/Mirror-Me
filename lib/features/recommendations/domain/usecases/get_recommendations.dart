import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/recommendations/domain/entities/recommendation.dart';
import 'package:mm/features/recommendations/domain/repositories/recommendation_repository.dart';

class GetRecommendations {
  final RecommendationRepository repository;

  GetRecommendations(this.repository);

  Future<Either<Failure, List<Recommendation>>> call(String userId) {
    return repository.getRecommendations(userId);
  }
}
