import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/submit_tryon.dart';
import 'tryon_event.dart';
import 'tryon_state.dart';

class TryOnBloc extends Bloc<TryOnEvent, TryOnState> {
  TryOnBloc({required SubmitTryOn submitTryOn})
    : _submitTryOn = submitTryOn,
      super(TryOnState.initial()) {
    on<SubmitTryOnRequested>(_onSubmitTryOnRequested);
  }

  final SubmitTryOn _submitTryOn;

  Future<void> _onSubmitTryOnRequested(
    SubmitTryOnRequested event,
    Emitter<TryOnState> emit,
  ) async {
    emit(state.copyWith(status: TryOnStatus.loading, message: null));
    try {
      final result = await _submitTryOn(
        userId: event.userId,
        photoBytes: event.photoBytes,
        wardrobeItemId: event.wardrobeItemId,
        wardrobeItemName: event.wardrobeItemName,
        wardrobeItemImageUrl: event.wardrobeItemImageUrl,
      );
      emit(
        state.copyWith(
          status: TryOnStatus.success,
          result: result,
          message: 'AI analysis complete!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: TryOnStatus.failure, message: e.toString()));
    }
  }
}
