import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/calendar_event.dart';

class CalendarRemoteDataSource {
  CalendarRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<CalendarEvent>> watchEvents(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('calendar')
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CalendarEvent(
                  id: doc.id,
                  title: (doc.data()['title'] as String?) ?? 'Event',
                  date: (doc.data()['date'] as String?) ?? '',
                ),
              )
              .toList(),
        );
  }

  Future<void> addEvent({
    required String uid,
    required String title,
    required String date,
  }) {
    return _firestore.collection('users').doc(uid).collection('calendar').add({
      'title': title,
      'date': date,
    });
  }
}
