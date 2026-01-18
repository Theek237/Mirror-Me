import '../repositories/profile_repository.dart';

class WatchTryOnCount {
  const WatchTryOnCount(this._repository);

  final ProfileRepository _repository;

  Stream<int> call(String uid) => _repository.watchTryOnCount(uid);
}
