import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:mm/features/auth/presentation/pages/home_page.dart';
import 'package:mm/features/auth/presentation/pages/login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Cache the pages to prevent unnecessary rebuilds
  final HomePage _homePage = const HomePage();
  final LoginPage _loginPage = const LoginPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Only rebuild when authentication status actually changes
        final wasAuthenticated = previous is AuthAuthenticated;
        final isAuthenticated = current is AuthAuthenticated;
        return wasAuthenticated != isAuthenticated;
      },
      builder: (context, state) {
        debugPrint("AuthWrapper State: $state");
        if (state is AuthAuthenticated) {
          return _homePage;
        }
        return _loginPage;
      },
    );
  }
}
