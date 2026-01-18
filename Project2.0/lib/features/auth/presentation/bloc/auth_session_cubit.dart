import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/watch_auth_state.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated }

class AuthSessionState {
  const AuthSessionState({required this.status, this.user});

  final AuthSessionStatus status;
  final AuthUser? user;
}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit({required WatchAuthState watchAuthState})
    : _watchAuthState = watchAuthState,
      super(const AuthSessionState(status: AuthSessionStatus.unknown)) {
    _subscription = _watchAuthState().listen((user) {
      if (user == null) {
        emit(const AuthSessionState(status: AuthSessionStatus.unauthenticated));
      } else {
        emit(
          AuthSessionState(status: AuthSessionStatus.authenticated, user: user),
        );
      }
    });
  }

  final WatchAuthState _watchAuthState;
  StreamSubscription<AuthUser?>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
