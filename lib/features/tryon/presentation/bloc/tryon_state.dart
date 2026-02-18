part of 'tryon_bloc.dart';

abstract class TryOnState extends Equatable {
  const TryOnState();

  @override
  List<Object?> get props => [];
}

class TryOnInitialState extends TryOnState {
  const TryOnInitialState();
}

class TryOnLoadingState extends TryOnState {
  final String message;

  const TryOnLoadingState({this.message = 'Processing...'});

  @override
  List<Object> get props => [message];
}

class TryOnGeneratingState extends TryOnState {
  const TryOnGeneratingState();
}

class TryOnGeneratedState extends TryOnState {
  final Uint8List resultImageBytes;
  final String poseImageUrl;
  final String clothingImageUrl;

  const TryOnGeneratedState({
    required this.resultImageBytes,
    required this.poseImageUrl,
    required this.clothingImageUrl,
  });

  @override
  List<Object> get props => [resultImageBytes, poseImageUrl, clothingImageUrl];
}

class TryOnSavedState extends TryOnState {
  final TryOnResult result;

  const TryOnSavedState({required this.result});

  @override
  List<Object> get props => [result];
}

class TryOnResultsLoadedState extends TryOnState {
  final List<TryOnResult> results;

  const TryOnResultsLoadedState({required this.results});

  @override
  List<Object> get props => [results];
}

class TryOnFavoriteToggledState extends TryOnState {
  final TryOnResult result;

  const TryOnFavoriteToggledState({required this.result});

  @override
  List<Object> get props => [result];
}

class TryOnErrorState extends TryOnState {
  final String message;

  const TryOnErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class TryOnDeletedState extends TryOnState {
  final String resultId;

  const TryOnDeletedState({required this.resultId});

  @override
  List<Object> get props => [resultId];
}
