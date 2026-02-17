import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/tryon/domain/repositories/tryon_repository.dart';

class DeleteTryOnResult {
  final TryOnRepository repository;

  DeleteTryOnResult(this.repository);

  Future<Either<Failure, void>> call(String resultId) {
    return repository.deleteTryOnResult(resultId);
  }
}
