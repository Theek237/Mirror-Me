import '../repositories/calendar_repository.dart';

class AddCalendarEvent {
  const AddCalendarEvent(this._repository);

  final CalendarRepository _repository;

  Future<void> call({
    required String uid,
    required String title,
    required String date,
  }) {
    return _repository.addEvent(uid: uid, title: title, date: date);
  }
}
