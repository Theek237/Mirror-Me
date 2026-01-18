import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_calendar_event.dart';
import '../../domain/usecases/watch_calendar_events.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({
    required WatchCalendarEvents watchCalendarEvents,
    required AddCalendarEvent addCalendarEvent,
  }) : _watchCalendarEvents = watchCalendarEvents,
       _addCalendarEvent = addCalendarEvent,
       super(CalendarState.initial()) {
    on<CalendarStarted>(_onStarted);
    on<CalendarAddRequested>(_onAddRequested);
    on<CalendarMessageCleared>(_onMessageCleared);
  }

  final WatchCalendarEvents _watchCalendarEvents;
  final AddCalendarEvent _addCalendarEvent;
  StreamSubscription<List>? _subscription;

  Future<void> _onStarted(
    CalendarStarted event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading, message: null));
    await _subscription?.cancel();
    _subscription = _watchCalendarEvents(event.uid).listen(
      (events) {
        emit(state.copyWith(status: CalendarStatus.idle, events: events));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: CalendarStatus.failure,
            message: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> _onAddRequested(
    CalendarAddRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.saving, message: null));
    try {
      await _addCalendarEvent(
        uid: event.uid,
        title: event.title,
        date: event.date,
      );
      emit(state.copyWith(status: CalendarStatus.idle));
    } catch (e) {
      emit(
        state.copyWith(status: CalendarStatus.failure, message: e.toString()),
      );
    }
  }

  void _onMessageCleared(
    CalendarMessageCleared event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(message: null));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
