import '../repositories/profile_repository.dart';

class WatchRecommendationsCount {
  const WatchRecommendationsCount(this._repository);

  final ProfileRepository _repository;

  Stream<int> call(String uid) => _repository.watchRecommendationsCount(uid);
}
