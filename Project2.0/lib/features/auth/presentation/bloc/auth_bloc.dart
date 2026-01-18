import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignIn signIn,
    required SignUp signUp,
    required SignInWithGoogle signInWithGoogle,
    required SendPasswordReset sendPasswordReset,
    required SignOut signOut,
  }) : _signIn = signIn,
       _signUp = signUp,
       _signInWithGoogle = signInWithGoogle,
       _sendPasswordReset = sendPasswordReset,
       _signOut = signOut,
       super(AuthState.initial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  final SignIn _signIn;
  final SignUp _signUp;
  final SignInWithGoogle _signInWithGoogle;
  final SendPasswordReset _sendPasswordReset;
  final SignOut _signOut;

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthActionStatus.loading, message: null));
    try {
      await _signIn(email: event.email, password: event.password);
      emit(state.copyWith(status: AuthActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthActionStatus.failure, message: _mapError(e)),
      );
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthActionStatus.loading, message: null));
    try {
      await _signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      emit(state.copyWith(status: AuthActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthActionStatus.failure, message: _mapError(e)),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthActionStatus.loading, message: null));
    try {
      await _signInWithGoogle();
      emit(state.copyWith(status: AuthActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthActionStatus.failure, message: _mapError(e)),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthActionStatus.loading, message: null));
    try {
      await _sendPasswordReset(event.email);
      emit(
        state.copyWith(
          status: AuthActionStatus.success,
          message: 'Password reset email sent.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthActionStatus.failure, message: _mapError(e)),
      );
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthActionStatus.loading, message: null));
    try {
      await _signOut();
      emit(state.copyWith(status: AuthActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthActionStatus.failure, message: _mapError(e)),
      );
    }
  }

  String _mapError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'invalid-credential':
          return 'Invalid email or password';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled';
        case 'unknown':
          final message = (error.message ?? '').toUpperCase();
          if (message.contains('CONFIGURATION_NOT_FOUND')) {
            return 'Firebase configuration not found for this app. Re-check google-services.json and enable Auth in Firebase.';
          }
          if (message.contains('API_KEY_INVALID')) {
            return 'Invalid Firebase API key. Re-run FlutterFire configure and rebuild.';
          }
          return error.message ?? 'Authentication failed';
        default:
          return error.message ?? 'Authentication failed';
      }
    }

    final fallback = error.toString().replaceAll('Exception: ', '');
    if (fallback.toLowerCase().contains('google sign-in cancelled')) {
      return 'Sign-in cancelled.';
    }
    return fallback;
  }
}
