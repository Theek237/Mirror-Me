import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AuthUser?> authStateChanges() => _remote.authStateChanges();

  @override
  Future<void> signIn({required String email, required String password}) {
    return _remote.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _remote.signUp(email: email, password: password, fullName: fullName);
  }

  @override
  Future<void> signInWithGoogle() => _remote.signInWithGoogle();

  @override
  Future<void> sendPasswordReset(String email) =>
      _remote.sendPasswordReset(email);

  @override
  Future<void> signOut() => _remote.signOut();
}
