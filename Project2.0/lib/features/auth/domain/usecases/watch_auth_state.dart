import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();
}
