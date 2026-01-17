part of 'gallery_bloc.dart';

sealed class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object> get props => [];
}

class GalleryInitialState extends GalleryState {}

class GalleryLoadingState extends GalleryState {}

class GalleryLoadedState extends GalleryState {
  final List<UserImageModel> images;

  const GalleryLoadedState({required this.images});

  @override
  List<Object> get props => [images];
}

class GalleryErrorState extends GalleryState {
  final String message;

  const GalleryErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
