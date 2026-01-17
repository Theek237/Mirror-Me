import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/domain/entities/tryon_result.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';

class SaveTryOnResult {
  final TryOnRepository repository;

  SaveTryOnResult(this.repository);

  Future<Either<Failure, TryOnResult>> call({
    required String userId,
    required String poseImageUrl,
    required String clothingImageUrl,
    required Uint8List resultImageBytes,
    String? prompt,
  }) {
    return repository.saveTryOnResult(
      userId: userId,
      poseImageUrl: poseImageUrl,
      clothingImageUrl: clothingImageUrl,
      resultImageBytes: resultImageBytes,
      prompt: prompt,
    );
  }
}
