import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wardrobe_item_model.dart';

class WardrobeRemoteDataSource {
  WardrobeRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<WardrobeItemModel>> watchWardrobeItems(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WardrobeItemModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
}
