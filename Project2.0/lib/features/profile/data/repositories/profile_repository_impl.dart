import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Stream<UserProfile> watchUserProfile(String uid) =>
      _remote.watchUserProfile(uid);

  @override
  Stream<int> watchWardrobeCount(String uid) => _remote.watchWardrobeCount(uid);

  @override
  Stream<int> watchTryOnCount(String uid) => _remote.watchTryOnCount(uid);

  @override
  Stream<int> watchFavoritesCount(String uid) =>
      _remote.watchFavoritesCount(uid);

  @override
  Stream<int> watchRecommendationsCount(String uid) =>
      _remote.watchRecommendationsCount(uid);
}
