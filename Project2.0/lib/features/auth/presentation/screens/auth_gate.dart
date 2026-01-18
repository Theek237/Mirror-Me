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
    print('🔐 AuthGate initState');
    // Show splash screen for a brief moment then check auth
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        print('🔐 AuthGate hiding splash screen');
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🔐 AuthGate build - showSplash: $_showSplash');
    // Show splash screen initially
    if (_showSplash) {
      return const SplashScreen();
    }

    return BlocProvider(
      create: (_) {
        print('🔐 Creating AuthSessionCubit');
        return sl<AuthSessionCubit>();
      },
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, state) {
          print('🔐 AuthSession state: ${state.status}');
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
