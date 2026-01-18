import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'features/analytics_screen.dart';
import 'features/calendar_screen.dart';
import 'features/collections_screen.dart';
import 'features/share_cards_screen.dart';
import 'features/style_quiz_screen.dart';
import 'features/tryon_history_screen.dart';

import '../core/di/injection.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/profile/domain/entities/user_profile.dart';
import '../features/profile/domain/usecases/watch_favorites_count.dart';
import '../features/profile/domain/usecases/watch_recommendations_count.dart';
import '../features/profile/domain/usecases/watch_tryon_count.dart';
import '../features/profile/domain/usecases/watch_user_profile.dart';
import '../features/profile/domain/usecases/watch_wardrobe_count.dart';
import '../theme/app_theme.dart';
import '../widgets/cyber_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to view your profile.'));
    }

    final watchUserProfile = sl<WatchUserProfile>();
    final watchWardrobeCount = sl<WatchWardrobeCount>();
    final watchTryOnCount = sl<WatchTryOnCount>();
    final watchFavoritesCount = sl<WatchFavoritesCount>();
    final watchRecommendationsCount = sl<WatchRecommendationsCount>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(
                user,
                watchUserProfile,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Stats
              _buildStats(
                user.uid,
                watchWardrobeCount: watchWardrobeCount,
                watchTryOnCount: watchTryOnCount,
                watchFavoritesCount: watchFavoritesCount,
                watchRecommendationsCount: watchRecommendationsCount,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Power Features
              _buildPowerFeatures(
                context,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Settings
              _buildSettings(
                context,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Logout
              _buildLogoutButton(
                context,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user, WatchUserProfile watchUserProfile) {
    return StreamBuilder<UserProfile>(
      stream: watchUserProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.fullName ?? user.displayName ?? 'MirrorMe User';
        final email = profile?.email ?? user.email ?? '';

        return Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: AppTheme.neonGlow(AppTheme.neonCyan, blur: 15),
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppTheme.backgroundDark,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(email, style: AppTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.neonGreen.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: AppTheme.neonGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PRO STYLIST',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.neonGreen,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NeonCard(
              glowColor: AppTheme.error,
              padding: const EdgeInsets.all(10),
              onTap: () => _showLogoutDialog(context),
              child: const Icon(Icons.logout, color: AppTheme.error, size: 20),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStats(
    String uid, {
    required WatchWardrobeCount watchWardrobeCount,
    required WatchTryOnCount watchTryOnCount,
    required WatchFavoritesCount watchFavoritesCount,
    required WatchRecommendationsCount watchRecommendationsCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'YOUR STATS',
          subtitle: 'Style journey overview',
          icon: Icons.insights,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCardStream(
                stream: watchWardrobeCount(uid),
                label: 'Wardrobe',
                icon: Icons.checkroom,
                color: AppTheme.neonCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCardStream(
                stream: watchTryOnCount(uid),
                label: 'Try-Ons',
                icon: Icons.auto_awesome,
                color: AppTheme.neonPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCardStream(
                stream: watchFavoritesCount(uid),
                label: 'Favorites',
                icon: Icons.favorite,
                color: AppTheme.neonPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCardStream(
                stream: watchRecommendationsCount(uid),
                label: 'Outfits',
                icon: Icons.style,
                color: AppTheme.neonGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardStream({
    required Stream<int> stream,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return StatCard(
          value: count.toString(),
          label: label,
          icon: icon,
          color: color,
        );
      },
    );
  }

  Widget _buildPowerFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'POWER FEATURES',
          subtitle: 'Unlock your style potential',
          icon: Icons.bolt,
        ),
        const SizedBox(height: 16),
        _buildFeatureGrid(context),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.quiz,
        label: 'Style Quiz',
        color: AppTheme.neonCyan,
        onTap: () => _navigate(context, const StyleQuizScreen()),
      ),
      _FeatureItem(
        icon: Icons.analytics,
        label: 'Analytics',
        color: AppTheme.neonPurple,
        onTap: () => _navigate(context, const ClosetAnalyticsScreen()),
      ),
      _FeatureItem(
        icon: Icons.calendar_month,
        label: 'Calendar',
        color: AppTheme.neonPink,
        onTap: () => _navigate(context, const OutfitCalendarScreen()),
      ),
      _FeatureItem(
        icon: Icons.collections,
        label: 'Collections',
        color: AppTheme.neonOrange,
        onTap: () => _navigate(context, const CollectionsScreen()),
      ),
      _FeatureItem(
        icon: Icons.history,
        label: 'History',
        color: AppTheme.neonBlue,
        onTap: () => _navigate(context, const TryOnHistoryScreen()),
      ),
      _FeatureItem(
        icon: Icons.share,
        label: 'Share',
        color: AppTheme.neonGreen,
        onTap: () => _navigate(context, const ShareCardsScreen()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return NeonCard(
          glowColor: feature.color,
          padding: const EdgeInsets.all(12),
          onTap: feature.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, color: feature.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                feature.label,
                style: AppTheme.labelLarge.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'SETTINGS',
          subtitle: 'Customize your experience',
          icon: Icons.settings,
        ),
        const SizedBox(height: 16),
        _buildSettingsTile(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Securely log out of MirrorMe',
          color: AppTheme.error,
          context: context,
          onTap: () => _showLogoutDialog(context),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage alerts and reminders',
          color: AppTheme.neonCyan,
          context: context,
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          subtitle: 'Control your data',
          color: AppTheme.neonPurple,
          context: context,
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs and contact us',
          color: AppTheme.neonPink,
          context: context,
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'About MirrorMe',
          subtitle: 'Version 1.0.0',
          color: AppTheme.neonGreen,
          context: context,
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return NeonCard(
      glowColor: color,
      padding: const EdgeInsets.all(16),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title coming soon!'),
                backgroundColor: AppTheme.surfaceDark,
              ),
            );
          },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTheme.bodyMedium),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppTheme.textMuted, size: 16),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: NeonCard(
        glowColor: AppTheme.error,
        padding: EdgeInsets.zero,
        onTap: () => _showLogoutDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppTheme.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'LOGOUT',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.error,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Logout', style: AppTheme.headlineSmall),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from MirrorMe?',
            style: AppTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.labelLarge.copyWith(color: AppTheme.textMuted),
              ),
            ),
            GradientButton(
              text: 'Logout',
              gradient: const LinearGradient(
                colors: [AppTheme.error, Color(0xFFFF6B6B)],
              ),
              height: 44,
              onPressed: () async {
                await sl<SignOut>()();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
