import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
