import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/domain/entities/tryon_result.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';

class ToggleTryOnFavorite {
  final TryOnRepository repository;

  ToggleTryOnFavorite(this.repository);

  Future<Either<Failure, TryOnResult>> call({
    required String resultId,
    required bool isFavorite,
  }) {
    return repository.toggleFavorite(resultId, isFavorite);
  }
}
