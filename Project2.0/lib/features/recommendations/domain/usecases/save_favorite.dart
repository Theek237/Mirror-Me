import '../entities/recommendation.dart';
import '../repositories/recommendations_repository.dart';

class SaveFavorite {
  SaveFavorite(this._repository);

  final RecommendationsRepository _repository;

  Future<void> call({
    required String uid,
    required String occasion,
    required Recommendation recommendation,
  }) {
    return _repository.saveFavorite(
      uid: uid,
      occasion: occasion,
      recommendation: recommendation,
    );
  }
}
