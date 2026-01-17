import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/features/recommendations/domain/entities/recommendation.dart';
import 'package:mm/features/recommendations/domain/usecases/generate_recommendation.dart';
import 'package:mm/features/recommendations/domain/usecases/save_recommendation.dart';
import 'package:mm/features/recommendations/domain/usecases/get_recommendations.dart';

part 'recommendation_event.dart';
part 'recommendation_state.dart';

class RecommendationBloc
    extends Bloc<RecommendationEvent, RecommendationState> {
  final GenerateRecommendation generateRecommendation;
  final SaveRecommendation saveRecommendation;
  final GetRecommendations getRecommendations;

  RecommendationBloc({
    required this.generateRecommendation,
    required this.saveRecommendation,
    required this.getRecommendations,
  }) : super(RecommendationInitialState()) {
    on<RecommendationGenerateEvent>(_onGenerate);
    on<RecommendationSaveEvent>(_onSave);
    on<RecommendationLoadHistoryEvent>(_onLoadHistory);
    on<RecommendationResetEvent>(_onReset);
  }

  Future<void> _onGenerate(
    RecommendationGenerateEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationGeneratingState());

    final result = await generateRecommendation(
      imageBytes: event.imageBytes,
      customPrompt: event.customPrompt,
    );

    result.fold(
      (failure) => emit(RecommendationErrorState(message: failure.message)),
      (text) => emit(RecommendationGeneratedState(recommendationText: text)),
    );
  }

  Future<void> _onSave(
    RecommendationSaveEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoadingState());

    final result = await saveRecommendation(
      userId: event.userId,
      imageUrl: event.imageUrl,
      recommendationText: event.recommendationText,
      imageSource: event.imageSource,
    );

    result.fold(
      (failure) => emit(RecommendationErrorState(message: failure.message)),
      (recommendation) =>
          emit(RecommendationSavedState(recommendation: recommendation)),
    );
  }

  Future<void> _onLoadHistory(
    RecommendationLoadHistoryEvent event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoadingState());

    final result = await getRecommendations(event.userId);

    result.fold(
      (failure) => emit(RecommendationErrorState(message: failure.message)),
      (recommendations) => emit(
        RecommendationHistoryLoadedState(recommendations: recommendations),
      ),
    );
  }

  void _onReset(
    RecommendationResetEvent event,
    Emitter<RecommendationState> emit,
  ) {
    emit(RecommendationInitialState());
  }
}
