import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class CalendarStarted extends CalendarEvent {
  const CalendarStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class CalendarAddRequested extends CalendarEvent {
  const CalendarAddRequested({
    required this.uid,
    required this.title,
    required this.date,
  });

  final String uid;
  final String title;
  final String date;

  @override
  List<Object?> get props => [uid, title, date];
}

class CalendarMessageCleared extends CalendarEvent {
  const CalendarMessageCleared();
}
