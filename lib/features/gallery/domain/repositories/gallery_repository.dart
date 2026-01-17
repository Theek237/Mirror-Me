import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/gallery/data/models/user_image_model.dart';

abstract class GalleryRepository {
  Future<Either<Failure, List<UserImageModel>>> getUserImages(String userId);
  Future<Either<Failure, void>> addUserImage(
    String userId,
    String poseName,
    String? description,
    File imageFile,
  );
  Future<Either<Failure, void>> deleteUserImage(String userId, String imageId);
}
