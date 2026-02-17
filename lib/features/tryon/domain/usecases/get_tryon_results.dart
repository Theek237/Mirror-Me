import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/domain/entities/tryon_result.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';

class GetTryOnResults {
  final TryOnRepository repository;

  GetTryOnResults(this.repository);

  Future<Either<Failure, List<TryOnResult>>> call(String userId) {
    return repository.getTryOnResults(userId);
  }
}
