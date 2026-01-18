import '../entities/favorite_recommendation.dart';
import '../repositories/recommendations_repository.dart';

class WatchFavorites {
  WatchFavorites(this._repository);

  final RecommendationsRepository _repository;

  Stream<List<FavoriteRecommendation>> call(String uid) {
    return _repository.watchFavorites(uid);
  }
}
