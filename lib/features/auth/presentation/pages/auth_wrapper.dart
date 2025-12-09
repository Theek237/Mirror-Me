import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/features/auth/presentation/bloc/auth%20bloc/auth_bloc.dart';
import 'package:mm/features/auth/presentation/pages/home_page.dart';
import 'package:mm/features/auth/presentation/pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc,AuthState>(
      builder: (context, state) {
        print("AuthWrapper State: $state");
        if (state is AuthAuthenticated) {
          return const HomePage();
        } else if (state is AuthUnauthenticated || state is AuthError || state is AuthLoading) {
          return const LoginPage();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}