import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mirror_me/theme/app_theme.dart';
import 'package:mirror_me/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({super.key, this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('💫 SplashScreen initState');
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && widget.onComplete != null) {
        print('💫 SplashScreen onComplete callback');
        widget.onComplete!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('💫 SplashScreen build');
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 100, showText: true),
            const SizedBox(height: 12),
            Text(
              'AI-Powered Virtual Stylist',
              style: AppTheme.bodyMedium,
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 50),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.surfaceLight,
                valueColor: const AlwaysStoppedAnimation(AppTheme.neonCyan),
                minHeight: 3,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
