import '../repositories/auth_repository.dart';

class SignOut {
  SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
