import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/features/tryon/domain/entities/tryon_result.dart';
import 'package:mm/features/tryon/domain/usecases/generate_tryon.dart';
import 'package:mm/features/tryon/domain/usecases/get_tryon_results.dart';
import 'package:mm/features/tryon/domain/usecases/save_tryon_result.dart';

part 'tryon_event.dart';
part 'tryon_state.dart';

class TryOnBloc extends Bloc<TryOnEvent, TryOnState> {
  final GenerateTryOn generateTryOn;
  final SaveTryOnResult saveTryOnResult;
  final GetTryOnResults getTryOnResults;

  TryOnBloc({
    required this.generateTryOn,
    required this.saveTryOnResult,
    required this.getTryOnResults,
  }) : super(const TryOnInitialState()) {
    on<TryOnGenerateEvent>(_onGenerate);
    on<TryOnSaveResultEvent>(_onSaveResult);
    on<TryOnLoadResultsEvent>(_onLoadResults);
    on<TryOnResetEvent>(_onReset);
  }

  Future<void> _onGenerate(
    TryOnGenerateEvent event,
    Emitter<TryOnState> emit,
  ) async {
    emit(const TryOnGeneratingState());

    final result = await generateTryOn(
      poseImageBytes: event.poseImageBytes,
      clothingImageBytes: event.clothingImageBytes,
      customPrompt: event.customPrompt,
    );

    result.fold(
      (failure) => emit(TryOnErrorState(message: failure.message)),
      (imageBytes) => emit(
        TryOnGeneratedState(
          resultImageBytes: imageBytes,
          poseImageUrl: event.poseImageUrl,
          clothingImageUrl: event.clothingImageUrl,
        ),
      ),
    );
  }

  Future<void> _onSaveResult(
    TryOnSaveResultEvent event,
    Emitter<TryOnState> emit,
  ) async {
    emit(const TryOnLoadingState(message: 'Saving result...'));

    final result = await saveTryOnResult(
      userId: event.userId,
      poseImageUrl: event.poseImageUrl,
      clothingImageUrl: event.clothingImageUrl,
      resultImageBytes: event.resultImageBytes,
      prompt: event.prompt,
    );

    result.fold(
      (failure) => emit(TryOnErrorState(message: failure.message)),
      (savedResult) => emit(TryOnSavedState(result: savedResult)),
    );
  }

  Future<void> _onLoadResults(
    TryOnLoadResultsEvent event,
    Emitter<TryOnState> emit,
  ) async {
    emit(const TryOnLoadingState(message: 'Loading results...'));

    final result = await getTryOnResults(event.userId);

    result.fold(
      (failure) => emit(TryOnErrorState(message: failure.message)),
      (results) => emit(TryOnResultsLoadedState(results: results)),
    );
  }

  void _onReset(TryOnResetEvent event, Emitter<TryOnState> emit) {
    emit(const TryOnInitialState());
  }
}
