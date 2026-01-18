import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mirror_me/core/di/injection.dart';
import 'package:mirror_me/features/recommendations/domain/entities/favorite_recommendation.dart';
import 'package:mirror_me/features/recommendations/domain/entities/recommendation.dart';
import 'package:mirror_me/features/recommendations/presentation/bloc/recommendations_bloc.dart';
import 'package:mirror_me/features/recommendations/presentation/bloc/recommendations_event.dart';
import 'package:mirror_me/features/recommendations/presentation/bloc/recommendations_state.dart';
import 'package:mirror_me/theme/app_theme.dart';
import 'package:mirror_me/widgets/cyber_widgets.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with TickerProviderStateMixin {
  final _auth = sl<FirebaseAuth>();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in.'));
    }

    return BlocProvider(
      create: (_) =>
          sl<RecommendationsBloc>()..add(RecommendationsStarted(uid: user.uid)),
      child: BlocConsumer<RecommendationsBloc, RecommendationsState>(
        listenWhen: (previous, current) =>
            previous.message != current.message && current.message != null,
        listener: (context, state) {
          final message = state.message;
          if (message == null) return;
          final isError = state.status == RecommendationsStatus.failure;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? AppTheme.error : AppTheme.success,
            ),
          );
          context.read<RecommendationsBloc>().add(
            const RecommendationsMessageCleared(),
          );
        },
        builder: (context, state) {
          final hasRecommendations = state.recommendations.isNotEmpty;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 24),

                    _buildOccasionSelector().animate().fadeIn(
                      delay: 200.ms,
                      duration: 400.ms,
                    ),

                    const SizedBox(height: 24),

                    _buildGenerateButton(
                      user.uid,
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    if (hasRecommendations) ...[
                      _buildRecommendations(
                        user.uid,
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      const SizedBox(height: 24),
                    ],

                    _buildFavorites(
                      user.uid,
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STYLE IDEAS',
              style: AppTheme.headlineMedium.copyWith(letterSpacing: 3),
            ),
            const SizedBox(height: 4),
            Text(
              'AI-powered outfit recommendations',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neonCyan),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.neonCyan.withOpacity(
                    0.5 + 0.3 * _pulseController.value,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(
                      0.3 * _pulseController.value,
                    ),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lightbulb,
                color: AppTheme.neonCyan,
                size: 24,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOccasionSelector() {
    final occasions = <_Occasion>[
      _Occasion('Casual', Icons.weekend, AppTheme.neonCyan),
      _Occasion('Work', Icons.work, AppTheme.neonBlue),
      _Occasion('Party', Icons.celebration, AppTheme.neonGreen),
      _Occasion('Date', Icons.favorite, AppTheme.error),
      _Occasion('Formal', Icons.business_center, AppTheme.neonBlue),
      _Occasion('Sport', Icons.fitness_center, AppTheme.neonGreen),
    ];

    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'SELECT OCCASION',
              subtitle: 'What are you dressing for?',
              icon: Icons.event,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: occasions.map((occasion) {
                final isSelected = state.selectedOccasion == occasion.name;
                return GestureDetector(
                  onTap: () => context.read<RecommendationsBloc>().add(
                    OccasionSelected(occasion: occasion.name),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? occasion.color.withOpacity(0.2)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? occasion.color
                            : AppTheme.glassBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? AppTheme.neonGlow(occasion.color, blur: 10)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          occasion.icon,
                          color: isSelected
                              ? occasion.color
                              : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          occasion.name,
                          style: AppTheme.labelLarge.copyWith(
                            color: isSelected
                                ? occasion.color
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenerateButton(String uid) {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        final isGenerating = state.status == RecommendationsStatus.loading;
        return SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: isGenerating ? 'GENERATING...' : 'GENERATE OUTFITS',
            icon: Icons.auto_awesome,
            gradient: AppTheme.primaryGradient,
            isLoading: isGenerating,
            onPressed: isGenerating
                ? null
                : () => context.read<RecommendationsBloc>().add(
                    GenerateRequested(uid: uid),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendations(String uid) {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'AI RECOMMENDATIONS',
              subtitle: 'For ${state.selectedOccasion.toLowerCase()} occasions',
              icon: Icons.style,
            ),
            const SizedBox(height: 16),
            ...state.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRecommendationCard(rec, uid, index),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationCard(Recommendation rec, String uid, int index) {
    final colors = [AppTheme.neonCyan, AppTheme.neonBlue, AppTheme.neonGreen];
    final color = colors[index % colors.length];

    final Widget card = NeonCard(
      glowColor: color,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.checkroom, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rec.title.isNotEmpty ? rec.title : 'Outfit ${index + 1}',
                  style: AppTheme.headlineSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rec.items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Text(item, style: AppTheme.bodyMedium),
              );
            }).toList(),
          ),
          if (rec.tip.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rec.tip,
                      style: AppTheme.bodyMedium.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<RecommendationsBloc>().add(
                    FavoriteSaved(uid: uid, recommendation: rec),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neonGreen),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: AppTheme.neonGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Save',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _shareRecommendation(rec),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neonBlue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.share,
                          color: AppTheme.neonBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Share',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.neonBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return card.animate().fadeIn(
      delay: Duration(milliseconds: 100 * index),
      duration: 400.ms,
    );
  }

  Widget _buildFavorites(String uid) {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'SAVED OUTFITS',
              subtitle: 'Your favorite combinations',
              icon: Icons.favorite,
            ),
            const SizedBox(height: 16),
            if (state.favorites.isEmpty)
              NeonCard(
                glowColor: AppTheme.neonCyan,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Text('No saved outfits yet', style: AppTheme.bodyMedium),
                  ],
                ),
              )
            else
              Column(
                children: state.favorites.take(5).map((favorite) {
                  return _buildFavoriteCard(uid, favorite);
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFavoriteCard(String uid, FavoriteRecommendation favorite) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: AppTheme.neonGreen,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.neonGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(favorite.title, style: AppTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${favorite.occasion} • ${favorite.items.length} items',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.read<RecommendationsBloc>().add(
                FavoriteDeleted(uid: uid, favoriteId: favorite.id),
              ),
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            ),
          ],
        ),
      ),
    );
  }

  void _shareRecommendation(Recommendation rec) {
    final title = rec.title.isNotEmpty ? rec.title : 'Outfit Recommendation';
    final items = rec.items.join(', ');
    final tip = rec.tip;

    Share.share(
      '$title\n\nItems: $items\n\nTip: $tip\n\nGenerated by MirrorMe AI',
    );
  }
}

class _Occasion {
  final String name;
  final IconData icon;
  final Color color;

  const _Occasion(this.name, this.icon, this.color);
}
