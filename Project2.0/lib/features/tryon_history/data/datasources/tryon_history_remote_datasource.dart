import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/tryon_history_item.dart';

class TryOnHistoryRemoteDataSource {
  TryOnHistoryRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<TryOnHistoryItem>> watchHistory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tryons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TryOnHistoryItem(
                  id: doc.id,
                  itemName:
                      (doc.data()['wardrobeItemName'] as String?) ?? 'Outfit',
                  status: (doc.data()['status'] as String?) ?? 'submitted',
                  createdAt: (doc.data()['createdAt'] as String?) ?? '',
                ),
              )
              .toList(),
        );
  }
}
