import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_tryon_history.dart';
import 'tryon_history_event.dart';
import 'tryon_history_state.dart';

class TryOnHistoryBloc extends Bloc<TryOnHistoryEvent, TryOnHistoryState> {
  TryOnHistoryBloc({required WatchTryOnHistory watchTryOnHistory})
    : _watchTryOnHistory = watchTryOnHistory,
      super(TryOnHistoryState.initial()) {
    on<TryOnHistoryStarted>(_onStarted);
  }

  final WatchTryOnHistory _watchTryOnHistory;
  StreamSubscription<List>? _subscription;

  Future<void> _onStarted(
    TryOnHistoryStarted event,
    Emitter<TryOnHistoryState> emit,
  ) async {
    emit(state.copyWith(status: TryOnHistoryStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchTryOnHistory(event.uid).listen(
      (items) {
        emit(state.copyWith(status: TryOnHistoryStatus.idle, items: items));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TryOnHistoryStatus.failure,
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
