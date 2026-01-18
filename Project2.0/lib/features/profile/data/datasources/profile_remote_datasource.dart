import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<UserProfile> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() ?? {};
      final fullName = (data['fullName'] as String?) ?? 'MirrorMe User';
      final email = (data['email'] as String?) ?? '';
      final photoUrl = data['photoUrl'] as String?;
      return UserProfile(fullName: fullName, email: email, photoUrl: photoUrl);
    });
  }

  Stream<int> watchWardrobeCount(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> watchTryOnCount(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tryons')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> watchFavoritesCount(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> watchRecommendationsCount(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
