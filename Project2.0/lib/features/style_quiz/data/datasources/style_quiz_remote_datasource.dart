import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/style_preferences.dart';

class StyleQuizRemoteDataSource {
  StyleQuizRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<StylePreferences> loadPreferences(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    final styles = (data?['stylePreferences'] as List?)?.cast<String>() ?? [];
    final occasions = (data?['styleOccasions'] as List?)?.cast<String>() ?? [];
    return StylePreferences(styles: styles, occasions: occasions);
  }

  Future<void> savePreferences(String uid, StylePreferences preferences) async {
    await _firestore.collection('users').doc(uid).set({
      'stylePreferences': preferences.styles,
      'styleOccasions': preferences.occasions,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
