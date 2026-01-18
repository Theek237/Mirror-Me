import '../entities/favorite_recommendation.dart';
import '../entities/recommendation.dart';

abstract class RecommendationsRepository {
  Stream<List<FavoriteRecommendation>> watchFavorites(String uid);
  Future<List<Recommendation>> generateRecommendations({
    required String uid,
    required String occasion,
  });
  Future<void> saveRecommendations({
    required String uid,
    required String occasion,
    required List<Recommendation> recommendations,
  });
  Future<void> saveFavorite({
    required String uid,
    required String occasion,
    required Recommendation recommendation,
  });
  Future<void> deleteFavorite({
    required String uid,
    required String favoriteId,
  });
}
