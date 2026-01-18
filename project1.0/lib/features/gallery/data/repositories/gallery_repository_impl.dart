import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:mm/features/gallery/data/models/user_image_model.dart';
import 'package:mm/features/gallery/domain/repositories/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryRemoteDataSource remoteDataSource;

  GalleryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserImageModel>>> getUserImages(
    String userId,
  ) async {
    try {
      final images = await remoteDataSource.getUserImages(userId);
      return Right(images);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addUserImage(
    String userId,
    String poseName,
    String? description,
    File imageFile,
  ) async {
    try {
      await remoteDataSource.addUserImage(
        userId,
        poseName,
        description,
        imageFile,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserImage(
    String userId,
    String imageId,
  ) async {
    try {
      await remoteDataSource.deleteUserImage(userId, imageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
