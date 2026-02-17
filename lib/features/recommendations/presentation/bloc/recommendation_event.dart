part of 'recommendation_bloc.dart';

sealed class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object?> get props => [];
}

class RecommendationGenerateEvent extends RecommendationEvent {
  final Uint8List imageBytes;
  final String? customPrompt;

  const RecommendationGenerateEvent({
    required this.imageBytes,
    this.customPrompt,
  });

  @override
  List<Object?> get props => [imageBytes, customPrompt];
}

class RecommendationSaveEvent extends RecommendationEvent {
  final String userId;
  final String imageUrl;
  final String recommendationText;
  final String? imageSource;

  const RecommendationSaveEvent({
    required this.userId,
    required this.imageUrl,
    required this.recommendationText,
    this.imageSource,
  });

  @override
  List<Object?> get props => [
    userId,
    imageUrl,
    recommendationText,
    imageSource,
  ];
}

class RecommendationLoadHistoryEvent extends RecommendationEvent {
  final String userId;

  const RecommendationLoadHistoryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RecommendationResetEvent extends RecommendationEvent {
  const RecommendationResetEvent();
}
