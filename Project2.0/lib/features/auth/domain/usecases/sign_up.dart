import '../repositories/auth_repository.dart';

class SignUp {
  SignUp(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
