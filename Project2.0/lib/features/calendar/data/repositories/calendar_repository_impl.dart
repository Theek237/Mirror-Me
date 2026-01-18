import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._remote);

  final CalendarRemoteDataSource _remote;

  @override
  Stream<List<CalendarEvent>> watchEvents(String uid) =>
      _remote.watchEvents(uid);

  @override
  Future<void> addEvent({
    required String uid,
    required String title,
    required String date,
  }) {
    return _remote.addEvent(uid: uid, title: title, date: date);
  }
}
