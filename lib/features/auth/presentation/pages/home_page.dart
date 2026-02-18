import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/core/theme/app_theme.dart';
import 'package:mm/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:mm/features/wardrobe/presentation/pages/wardrobe_page.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe_bloc/wardrobe_bloc.dart';
import 'package:mm/features/gallery/presentation/pages/gallery_page.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:mm/features/tryon/presentation/pages/tryon_page.dart';
import 'package:mm/features/tryon/presentation/bloc/tryon_bloc.dart';
import 'package:mm/features/tryon/presentation/pages/generated_images_page.dart';
import 'package:mm/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:mm/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:mm/injection_container.dart' as di;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        final user = state.user;
        final firstName = (user.name ?? 'User').split(' ').first;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Minimal top bar
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Mirror Me",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showProfileSheet(context),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Greeting
                  Text(
                    "Hi $firstName,",
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                      height: 1.1,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "what are we styling today?",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textSecondary,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Illustration — use a fixed height so it doesn't push content apart
                  SizedBox(
                    height: 240,
                    child: Center(
                      child: Image.asset(
                        'lib/features/auth/presentation/assets/homeillustration.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Two main actions — tall tappable tiles side by side
                  Row(
                    children: [
                      Expanded(
                        child: _MainTile(
                          label: "Try On",
                          subtitle: "See it on you",
                          icon: Icons.checkroom_rounded,
                          color: AppTheme.primaryColor,
                          onTap: () => _navigateToTryOn(context, user.uid),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _MainTile(
                          label: "Style Me",
                          subtitle: "Get suggestions",
                          icon: Icons.auto_awesome_outlined,
                          color: AppTheme.secondaryColor,
                          onTap: () =>
                              _navigateToRecommendations(context, user.uid),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Bottom row — compact actions
                  Row(
                    children: [
                      _SmallTile(
                        icon: Icons.dry_cleaning_outlined,
                        label: "Wardrobe",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WardrobePage(userId: user.uid),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _SmallTile(
                        icon: Icons.person_outline_rounded,
                        label: "Gallery",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GalleryPage(userId: user.uid),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _SmallTile(
                        icon: Icons.grid_view_rounded,
                        label: "Results",
                        onTap: () =>
                            _navigateToGeneratedImages(context, user.uid),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToTryOn(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<TryOnBloc>()),
            BlocProvider(create: (_) => di.sl<GalleryBloc>()),
            BlocProvider(create: (_) => di.sl<WardrobeBloc>()),
          ],
          child: TryOnPage(userId: userId),
        ),
      ),
    );
  }

  void _navigateToRecommendations(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<RecommendationBloc>()),
            BlocProvider(create: (_) => di.sl<GalleryBloc>()),
            BlocProvider(create: (_) => di.sl<WardrobeBloc>()),
            BlocProvider(create: (_) => di.sl<TryOnBloc>()),
          ],
          child: RecommendationsPage(userId: userId),
        ),
      ),
    );
  }

  void _navigateToGeneratedImages(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => di.sl<TryOnBloc>(),
          child: GeneratedImagesPage(userId: userId),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (state.user.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.user.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: AppTheme.secondaryColor,
                ),
                child: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Large feature tile
class _MainTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MainTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small bottom nav tile
class _SmallTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppTheme.primaryColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
