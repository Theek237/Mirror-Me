import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_closet_analytics.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required WatchClosetAnalytics watchClosetAnalytics})
    : _watchClosetAnalytics = watchClosetAnalytics,
      super(AnalyticsState.initial()) {
    on<AnalyticsStarted>(_onStarted);
  }

  final WatchClosetAnalytics _watchClosetAnalytics;
  StreamSubscription? _subscription;

  Future<void> _onStarted(
    AnalyticsStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchClosetAnalytics(event.uid).listen(
      (summary) {
        emit(state.copyWith(status: AnalyticsStatus.idle, analytics: summary));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: AnalyticsStatus.failure,
            message: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
