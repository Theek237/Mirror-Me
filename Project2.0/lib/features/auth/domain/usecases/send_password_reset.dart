import '../repositories/auth_repository.dart';

class SendPasswordReset {
  SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) => _repository.sendPasswordReset(email);
}
