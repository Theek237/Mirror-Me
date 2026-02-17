part of 'tryon_bloc.dart';

abstract class TryOnEvent extends Equatable {
  const TryOnEvent();

  @override
  List<Object?> get props => [];
}

class TryOnGenerateEvent extends TryOnEvent {
  final Uint8List poseImageBytes;
  final Uint8List clothingImageBytes;
  final String poseImageUrl;
  final String clothingImageUrl;
  final String? customPrompt;

  const TryOnGenerateEvent({
    required this.poseImageBytes,
    required this.clothingImageBytes,
    required this.poseImageUrl,
    required this.clothingImageUrl,
    this.customPrompt,
  });

  @override
  List<Object?> get props => [
    poseImageBytes,
    clothingImageBytes,
    poseImageUrl,
    clothingImageUrl,
    customPrompt,
  ];
}

class TryOnSaveResultEvent extends TryOnEvent {
  final String userId;
  final String poseImageUrl;
  final String clothingImageUrl;
  final Uint8List resultImageBytes;
  final String? prompt;

  const TryOnSaveResultEvent({
    required this.userId,
    required this.poseImageUrl,
    required this.clothingImageUrl,
    required this.resultImageBytes,
    this.prompt,
  });

  @override
  List<Object?> get props => [
    userId,
    poseImageUrl,
    clothingImageUrl,
    resultImageBytes,
    prompt,
  ];
}

class TryOnLoadResultsEvent extends TryOnEvent {
  final String userId;

  const TryOnLoadResultsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class TryOnToggleFavoriteEvent extends TryOnEvent {
  final String resultId;
  final bool isFavorite;

  const TryOnToggleFavoriteEvent({
    required this.resultId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [resultId, isFavorite];
}

class TryOnResetEvent extends TryOnEvent {
  const TryOnResetEvent();
}

class TryOnDeleteEvent extends TryOnEvent {
  final String resultId;

  const TryOnDeleteEvent({required this.resultId});

  @override
  List<Object> get props => [resultId];
}
