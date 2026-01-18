import '../repositories/profile_repository.dart';

class WatchWardrobeCount {
  const WatchWardrobeCount(this._repository);

  final ProfileRepository _repository;

  Stream<int> call(String uid) => _repository.watchWardrobeCount(uid);
}
