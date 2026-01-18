import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Logo
              const AppLogo(size: 100, showText: true),

              const SizedBox(height: 16),

              Text(
                'Your AI-Powered Virtual Stylist',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const Spacer(),

              // Features
              _buildFeatureRow(
                Icons.auto_awesome,
                'AI Try-On',
                'See yourself in any outfit',
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 16),

              _buildFeatureRow(
                Icons.checkroom,
                'Smart Wardrobe',
                'Organize your closet digitally',
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 16),

              _buildFeatureRow(
                Icons.style,
                'Style Tips',
                'Get personalized recommendations',
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _navigateTo(context, const SignUpScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: AppTheme.backgroundDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.backgroundDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => _navigateTo(context, const LoginScreen()),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.glassBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: AppTheme.labelLarge,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

              const SizedBox(height: 20),

              Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms, duration: 300.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.neonCyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
