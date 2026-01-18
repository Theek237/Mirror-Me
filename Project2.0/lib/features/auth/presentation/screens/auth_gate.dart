import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mirror_me/core/di/injection.dart';
import 'package:mirror_me/core/presentation/screens/home_screen.dart';
import 'package:mirror_me/core/presentation/screens/splash_screen.dart';
import 'package:mirror_me/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:mirror_me/features/auth/presentation/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash screen for a brief moment then check auth
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen initially
    if (_showSplash) {
      return const SplashScreen();
    }

    return BlocProvider(
      create: (_) => sl<AuthSessionCubit>(),
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, state) {
          if (state.status == AuthSessionStatus.unknown) {
            return const SplashScreen();
          }

          if (state.status == AuthSessionStatus.authenticated) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
