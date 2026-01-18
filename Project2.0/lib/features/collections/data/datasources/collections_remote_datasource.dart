import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/outfit_collection.dart';

class CollectionsRemoteDataSource {
  CollectionsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<OutfitCollection>> watchCollections(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('collections')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OutfitCollection(
                  id: doc.id,
                  name: (doc.data()['name'] as String?) ?? 'Collection',
                  createdAt: (doc.data()['createdAt'] as String?) ?? '',
                ),
              )
              .toList(),
        );
  }

  Future<void> createCollection({required String uid, required String name}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('collections')
        .add({'name': name, 'createdAt': DateTime.now().toIso8601String()});
  }
}
