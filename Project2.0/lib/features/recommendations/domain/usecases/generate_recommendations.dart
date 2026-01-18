import '../entities/recommendation.dart';
import '../repositories/recommendations_repository.dart';

class GenerateRecommendations {
  GenerateRecommendations(this._repository);

  final RecommendationsRepository _repository;

  Future<List<Recommendation>> call({
    required String uid,
    required String occasion,
  }) {
    return _repository.generateRecommendations(uid: uid, occasion: occasion);
  }
}
