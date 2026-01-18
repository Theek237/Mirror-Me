import '../entities/recommendation.dart';
import '../repositories/recommendations_repository.dart';

class SaveRecommendations {
  SaveRecommendations(this._repository);

  final RecommendationsRepository _repository;

  Future<void> call({
    required String uid,
    required String occasion,
    required List<Recommendation> recommendations,
  }) {
    return _repository.saveRecommendations(
      uid: uid,
      occasion: occasion,
      recommendations: recommendations,
    );
  }
}
