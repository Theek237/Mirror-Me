import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class WatchUserProfile {
  const WatchUserProfile(this._repository);

  final ProfileRepository _repository;

  Stream<UserProfile> call(String uid) => _repository.watchUserProfile(uid);
}
