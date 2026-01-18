import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/gemini_service.dart';
import '../models/favorite_recommendation_model.dart';
import '../models/recommendation_model.dart';

class RecommendationsRemoteDataSource {
  RecommendationsRemoteDataSource(this._firestore, this._geminiService);

  final FirebaseFirestore _firestore;
  final GeminiService _geminiService;

  Stream<List<FavoriteRecommendationModel>> watchFavorites(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    FavoriteRecommendationModel.fromMap(doc.id, doc.data()),
              )
              .toList();
        });
  }

  Future<List<Map<String, dynamic>>> fetchWardrobeItems(String uid) async {
    final wardrobeSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .get();

    return wardrobeSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'],
        'category': data['category'],
        'color': data['color'],
      };
    }).toList();
  }

  Future<List<RecommendationModel>> generateRecommendations({
    required List<Map<String, dynamic>> wardrobeItems,
    required String occasion,
  }) async {
    final recommendations = await _geminiService.generateOutfitRecommendations(
      wardrobeItems: wardrobeItems,
      occasion: occasion,
    );

    return recommendations
        .map((rec) => RecommendationModel.fromMap(rec))
        .toList();
  }

  Future<void> saveRecommendations({
    required String uid,
    required String occasion,
    required List<RecommendationModel> recommendations,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .add({
          'occasion': occasion,
          'outfits': recommendations.map((rec) => rec.toMap()).toList(),
          'createdAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> saveFavorite({
    required String uid,
    required String occasion,
    required RecommendationModel recommendation,
  }) async {
    await _firestore.collection('users').doc(uid).collection('favorites').add({
      ...recommendation.toMap(),
      'occasion': occasion,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteFavorite({
    required String uid,
    required String favoriteId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(favoriteId)
        .delete();
  }
}
