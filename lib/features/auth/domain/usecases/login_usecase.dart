import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/auth/domain/entities/user_entity.dart';
import 'package:mm/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase({required this.repository});

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    return await repository.loginWithEmail(email, password);
  }
}
