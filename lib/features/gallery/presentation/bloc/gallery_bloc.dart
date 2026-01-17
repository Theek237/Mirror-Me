import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mm/features/gallery/data/models/user_image_model.dart';
import 'package:mm/features/gallery/domain/repositories/gallery_repository.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepository repository;

  GalleryBloc({required this.repository}) : super(GalleryInitialState()) {
    on<GalleryLoadImagesEvent>((event, emit) async {
      emit(GalleryLoadingState());
      final result = await repository.getUserImages(event.userId);
      result.fold(
        (failure) => emit(GalleryErrorState(message: failure.message)),
        (images) => emit(GalleryLoadedState(images: images)),
      );
    });

    on<GalleryAddImageEvent>((event, emit) async {
      emit(GalleryLoadingState());
      final result = await repository.addUserImage(
        event.userId,
        event.poseName,
        event.description,
        event.imageFile,
      );
      await result.fold(
        (failure) async => emit(GalleryErrorState(message: failure.message)),
        (_) async {
          final loadResult = await repository.getUserImages(event.userId);
          loadResult.fold(
            (failure) => emit(GalleryErrorState(message: failure.message)),
            (images) => emit(GalleryLoadedState(images: images)),
          );
        },
      );
    });

    on<GalleryDeleteImageEvent>((event, emit) async {
      emit(GalleryLoadingState());
      final result = await repository.deleteUserImage(
        event.userId,
        event.imageId,
      );
      await result.fold(
        (failure) async => emit(GalleryErrorState(message: failure.message)),
        (_) async {
          final loadResult = await repository.getUserImages(event.userId);
          loadResult.fold(
            (failure) => emit(GalleryErrorState(message: failure.message)),
            (images) => emit(GalleryLoadedState(images: images)),
          );
        },
      );
    });
  }
}
