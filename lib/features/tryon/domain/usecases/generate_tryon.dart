import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';

class GenerateTryOn {
  final TryOnRepository repository;

  GenerateTryOn(this.repository);

  Future<Either<Failure, Uint8List>> call({
    required Uint8List poseImageBytes,
    required Uint8List clothingImageBytes,
    String? customPrompt,
  }) {
    return repository.generateTryOn(
      poseImageBytes: poseImageBytes,
      clothingImageBytes: clothingImageBytes,
      customPrompt: customPrompt,
    );
  }
}
