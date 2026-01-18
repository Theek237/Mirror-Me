import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_share_cards.dart';
import 'share_cards_event.dart';
import 'share_cards_state.dart';

class ShareCardsBloc extends Bloc<ShareCardsEvent, ShareCardsState> {
  ShareCardsBloc({required WatchShareCards watchShareCards})
    : _watchShareCards = watchShareCards,
      super(ShareCardsState.initial()) {
    on<ShareCardsStarted>(_onStarted);
  }

  final WatchShareCards _watchShareCards;
  StreamSubscription<List>? _subscription;

  Future<void> _onStarted(
    ShareCardsStarted event,
    Emitter<ShareCardsState> emit,
  ) async {
    emit(state.copyWith(status: ShareCardsStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchShareCards(event.uid).listen(
      (cards) {
        emit(state.copyWith(status: ShareCardsStatus.idle, cards: cards));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ShareCardsStatus.failure,
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
