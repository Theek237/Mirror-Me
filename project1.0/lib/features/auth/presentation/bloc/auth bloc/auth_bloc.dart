// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mm/features/auth/domain/entities/user_entity.dart';
import 'package:mm/features/auth/domain/usecases/get_currentuser_usecase.dart';
import 'package:mm/features/auth/domain/usecases/login_usecase.dart';
import 'package:mm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mm/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final GetCurrentuserUsecase getCurrentuserUsecase;
  final LogoutUsecase logoutUsecase;
  AuthBloc({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.getCurrentuserUsecase,
    required this.logoutUsecase,
  }) : super(AuthInitial()) {
    //App Start Check
    on<AuthCheckRequested>((event, emit) async {
      try {
        final user = await getCurrentuserUsecase();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        debugPrint('AuthCheckRequested error: $e');
        emit(AuthUnauthenticated());
      }
    });

    //Login Logic
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await loginUsecase(event.email, event.password);
        result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      } catch (e) {
        debugPrint('AuthLoginRequested error: $e');
        emit(AuthError(message: 'Login failed: ${e.toString()}'));
      }
    });

    //Register Logic
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await registerUsecase(
          event.email,
          event.password,
          event.name,
        );
        result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      } catch (e) {
        debugPrint('AuthRegisterRequested error: $e');
        emit(AuthError(message: 'Registration failed: ${e.toString()}'));
      }
    });

    //Google Login Logic - Not implemented yet
    on<AuthGoogleLoginRequested>((event, emit) async {
      emit(AuthError(message: 'Google Sign-In is not available yet'));
    });

    //Logout Logic
    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await logoutUsecase();
        emit(AuthUnauthenticated());
      } catch (e) {
        debugPrint('AuthLogoutRequested error: $e');
        emit(AuthUnauthenticated());
      }
    });
  }
}
