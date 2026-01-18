import '../repositories/profile_repository.dart';

class WatchFavoritesCount {
  const WatchFavoritesCount(this._repository);

  final ProfileRepository _repository;

  Stream<int> call(String uid) => _repository.watchFavoritesCount(uid);
}
