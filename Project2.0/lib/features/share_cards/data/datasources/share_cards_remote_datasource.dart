import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/recommendation_card.dart';

class ShareCardsRemoteDataSource {
  ShareCardsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<RecommendationCard>> watchRecent(String uid, {int limit = 5}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => RecommendationCard(
                  id: doc.id,
                  title: (doc.data()['title'] as String?) ?? 'Outfit',
                  items: (doc.data()['items'] as List?)?.cast<String>() ?? [],
                ),
              )
              .toList(),
        );
  }
}
