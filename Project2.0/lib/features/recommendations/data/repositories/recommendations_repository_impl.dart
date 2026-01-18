import '../../domain/entities/favorite_recommendation.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../datasources/recommendations_remote_datasource.dart';
import '../models/recommendation_model.dart';

class RecommendationsRepositoryImpl implements RecommendationsRepository {
  RecommendationsRepositoryImpl(this._remote);

  final RecommendationsRemoteDataSource _remote;

  @override
  Stream<List<FavoriteRecommendation>> watchFavorites(String uid) {
    return _remote.watchFavorites(uid);
  }

  @override
  Future<List<Recommendation>> generateRecommendations({
    required String uid,
    required String occasion,
  }) async {
    final wardrobeItems = await _remote.fetchWardrobeItems(uid);
    if (wardrobeItems.isEmpty) {
      throw StateError('EMPTY_WARDROBE');
    }
    return _remote.generateRecommendations(
      wardrobeItems: wardrobeItems,
      occasion: occasion,
    );
  }

  @override
  Future<void> saveRecommendations({
    required String uid,
    required String occasion,
    required List<Recommendation> recommendations,
  }) {
    final models = recommendations
        .map(
          (rec) => RecommendationModel(
            title: rec.title,
            items: rec.items,
            tip: rec.tip,
          ),
        )
        .toList();
    return _remote.saveRecommendations(
      uid: uid,
      occasion: occasion,
      recommendations: models,
    );
  }

  @override
  Future<void> saveFavorite({
    required String uid,
    required String occasion,
    required Recommendation recommendation,
  }) {
    final model = RecommendationModel(
      title: recommendation.title,
      items: recommendation.items,
      tip: recommendation.tip,
    );
    return _remote.saveFavorite(
      uid: uid,
      occasion: occasion,
      recommendation: model,
    );
  }

  @override
  Future<void> deleteFavorite({
    required String uid,
    required String favoriteId,
  }) {
    return _remote.deleteFavorite(uid: uid, favoriteId: favoriteId);
  }
}
