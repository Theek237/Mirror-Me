import 'package:dartz/dartz.dart';
import 'package:mm/core/errors/failure.dart';
import 'package:mm/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> registerWithEmail(
    String email,
    String password,
    String name,
  );
  // Future<Either<Failure,UserEntity>> loginWithGoogle();
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
