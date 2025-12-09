part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}


class AuthCheckRequested extends AuthEvent{}

class AuthLoginRequested extends AuthEvent{
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent{
  final String email;
  final String password;
  final String name;
  const AuthRegisterRequested({required this.email, required this.password, required this.name});
}

class AuthGoogleLoginRequested extends AuthEvent{}

class AuthLogoutRequested extends AuthEvent{}