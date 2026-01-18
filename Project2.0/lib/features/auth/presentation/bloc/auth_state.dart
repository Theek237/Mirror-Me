import 'package:equatable/equatable.dart';

enum AuthActionStatus { idle, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({required this.status, this.message});

  factory AuthState.initial() => const AuthState(status: AuthActionStatus.idle);

  final AuthActionStatus status;
  final String? message;

  AuthState copyWith({AuthActionStatus? status, String? message}) {
    return AuthState(status: status ?? this.status, message: message);
  }

  @override
  List<Object?> get props => [status, message];
}
