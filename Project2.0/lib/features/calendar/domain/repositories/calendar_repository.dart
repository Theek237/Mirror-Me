import '../entities/calendar_event.dart';

abstract class CalendarRepository {
  Stream<List<CalendarEvent>> watchEvents(String uid);
  Future<void> addEvent({
    required String uid,
    required String title,
    required String date,
  });
}
