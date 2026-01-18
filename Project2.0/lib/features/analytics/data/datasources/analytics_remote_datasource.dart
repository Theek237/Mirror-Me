import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/closet_analytics.dart';

class AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<ClosetAnalytics> watchClosetAnalytics(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wardrobe')
        .snapshots()
        .map((snapshot) {
          final Map<String, int> categoryCounts = {};
          final Map<String, int> colorCounts = {};

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final category = (data['category'] as String?) ?? 'Other';
            final color = (data['color'] as String?) ?? 'Neutral';
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
            colorCounts[color] = (colorCounts[color] ?? 0) + 1;
          }

          return ClosetAnalytics(
            categoryCounts: categoryCounts,
            colorCounts: colorCounts,
          );
        });
  }
}
