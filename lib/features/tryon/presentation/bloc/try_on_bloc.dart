// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:mm/features/tryon/domain/repositories/try_on_repository.dart';

// part 'try_on_event.dart';
// part 'try_on_state.dart';

// class TryOnBloc extends Bloc<TryOnEvent, TryOnState> {
//   final TryOnRepository _tryOnRepository;

//   TryOnBloc({required TryOnRepository tryOnRepository})
//       : _tryOnRepository = tryOnRepository,
//         super(TryOnInitial()) {
//     on<GenerateImageEvent>(_onGenerateImageEvent);
//   }

//   void _onGenerateImageEvent(
//     GenerateImageEvent event,
//     Emitter<TryOnState> emit,
//   ) async {
//     emit(TryOnLoading());
//     final result = await _tryOnRepository.generateImage(
//       event.userId,
//       event.userImage,
//       event.clothImage,
//     );
//     result.fold(
//       (failure) => emit(TryOnError(failure.message)),
//       (tryOnResult) => emit(TryOnLoaded(tryOnResult)),
//     );
//   }
// }
