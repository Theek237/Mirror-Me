import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/recommendations/domain/repositories/recommendation_repository.dart';

class GenerateRecommendation {
  final RecommendationRepository repository;

  GenerateRecommendation(this.repository);

  Future<Either<Failure, String>> call({
    required Uint8List imageBytes,
    String? customPrompt,
  }) {
    return repository.generateRecommendation(
      imageBytes: imageBytes,
      customPrompt: customPrompt,
    );
  }
}
