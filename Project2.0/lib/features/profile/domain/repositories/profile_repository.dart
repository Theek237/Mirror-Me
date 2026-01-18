import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile> watchUserProfile(String uid);
  Stream<int> watchWardrobeCount(String uid);
  Stream<int> watchTryOnCount(String uid);
  Stream<int> watchFavoritesCount(String uid);
  Stream<int> watchRecommendationsCount(String uid);
}
