import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

class WatchCalendarEvents {
  const WatchCalendarEvents(this._repository);

  final CalendarRepository _repository;

  Stream<List<CalendarEvent>> call(String uid) {
    return _repository.watchEvents(uid);
  }
}
