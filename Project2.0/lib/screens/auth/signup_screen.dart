import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) {
    context.read<AuthBloc>().add(const GoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state.status == AuthActionStatus.loading;
          final errorMessage = state.status == AuthActionStatus.failure
              ? state.message
              : null;

          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.glassBorder),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 20),

                      // Logo
                      _buildLogo(),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Create Account',
                        style: AppTheme.headlineLarge,
                      ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                      const SizedBox(height: 8),

                      Text(
                        'Start your personalized style journey',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                      const SizedBox(height: 32),

                      // Error message
                      if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms).shake(),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            _buildLabel('Full Name'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _nameController,
                              hint: 'Enter your name',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Email field
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password field
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Create a password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.textMuted,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Password strength
                            Text(
                              'Password must be at least 6 characters',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Sign up button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _submit(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonCyan,
                                  foregroundColor: AppTheme.backgroundDark,
                                  disabledBackgroundColor: AppTheme.neonCyan
                                      .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(
                                            AppTheme.backgroundDark,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'CREATE ACCOUNT',
                                        style: AppTheme.labelLarge.copyWith(
                                          color: AppTheme.backgroundDark,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.glassBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.glassBorder)),
                        ],
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                      const SizedBox(height: 24),

                      // Google sign up
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => _signInWithGoogle(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.glassBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://www.google.com/favicon.ico',
                                width: 20,
                                height: 20,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.g_mobiledata, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: AppTheme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                      const SizedBox(height: 32),

                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: AppTheme.labelLarge.copyWith(
                                color: AppTheme.neonCyan,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    const Widget logo = AppLogo(size: 70, showText: false);
    return logo
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTheme.labelLarge.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTheme.bodyLarge,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.textMuted),
        prefixIcon: Icon(prefixIcon, color: AppTheme.textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.neonPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
