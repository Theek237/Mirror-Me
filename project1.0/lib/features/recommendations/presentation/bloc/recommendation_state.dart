part of 'recommendation_bloc.dart';

sealed class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitialState extends RecommendationState {}

class RecommendationLoadingState extends RecommendationState {}

class RecommendationGeneratingState extends RecommendationState {}

class RecommendationGeneratedState extends RecommendationState {
  final String recommendationText;

  const RecommendationGeneratedState({required this.recommendationText});

  @override
  List<Object?> get props => [recommendationText];
}

class RecommendationSavedState extends RecommendationState {
  final Recommendation recommendation;

  const RecommendationSavedState({required this.recommendation});

  @override
  List<Object?> get props => [recommendation];
}

class RecommendationHistoryLoadedState extends RecommendationState {
  final List<Recommendation> recommendations;

  const RecommendationHistoryLoadedState({required this.recommendations});

  @override
  List<Object?> get props => [recommendations];
}

class RecommendationErrorState extends RecommendationState {
  final String message;

  const RecommendationErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
