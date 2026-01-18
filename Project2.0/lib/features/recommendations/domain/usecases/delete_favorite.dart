import '../repositories/recommendations_repository.dart';

class DeleteFavorite {
  DeleteFavorite(this._repository);

  final RecommendationsRepository _repository;

  Future<void> call({required String uid, required String favoriteId}) {
    return _repository.deleteFavorite(uid: uid, favoriteId: favoriteId);
  }
}
