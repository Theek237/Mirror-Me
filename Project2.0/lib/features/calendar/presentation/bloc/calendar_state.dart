import 'package:equatable/equatable.dart';

import '../../domain/entities/calendar_event.dart';

enum CalendarStatus { idle, loading, saving, failure }

class CalendarState extends Equatable {
  const CalendarState({
    required this.status,
    required this.events,
    this.message,
  });

  factory CalendarState.initial() {
    return const CalendarState(
      status: CalendarStatus.idle,
      events: <CalendarEvent>[],
    );
  }

  final CalendarStatus status;
  final List<CalendarEvent> events;
  final String? message;

  CalendarState copyWith({
    CalendarStatus? status,
    List<CalendarEvent>? events,
    String? message,
  }) {
    return CalendarState(
      status: status ?? this.status,
      events: events ?? this.events,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, events, message];
}
