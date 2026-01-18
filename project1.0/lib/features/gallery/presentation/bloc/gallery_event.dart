part of 'gallery_bloc.dart';

sealed class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

class GalleryLoadImagesEvent extends GalleryEvent {
  final String userId;
  const GalleryLoadImagesEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class GalleryAddImageEvent extends GalleryEvent {
  final String userId;
  final String poseName;
  final String? description;
  final File imageFile;

  const GalleryAddImageEvent({
    required this.userId,
    required this.poseName,
    this.description,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [userId, poseName, description, imageFile];
}

class GalleryDeleteImageEvent extends GalleryEvent {
  final String userId;
  final String imageId;

  const GalleryDeleteImageEvent({required this.userId, required this.imageId});

  @override
  List<Object> get props => [userId, imageId];
}
