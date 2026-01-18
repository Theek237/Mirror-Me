import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../core/di/injection.dart';
import '../features/tryon/presentation/bloc/tryon_bloc.dart';
import '../features/tryon/presentation/bloc/tryon_event.dart';
import '../features/tryon/presentation/bloc/tryon_state.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cyber_widgets.dart';
import '../features/camera/presentation/camera_screen.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen>
    with TickerProviderStateMixin {
  final _auth = sl<FirebaseAuth>();
  final _firestore = sl<FirebaseFirestore>();
  final _picker = ImagePicker();
  final _geminiService = sl<GeminiService>();

  late AnimationController _pulseController;
  late AnimationController _loadingController;

  XFile? _userPhoto;
  Uint8List? _webPhotoBytes;
  String? _selectedItemId;
  String? _selectedItemName;
  String? _selectedItemImageUrl;
  Map<String, dynamic>? _aiResult;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to use Try-On.'));
    }

    return BlocProvider(
      create: (_) => sl<TryOnBloc>(),
      child: BlocConsumer<TryOnBloc, TryOnState>(
        listener: (context, state) {
          if (state.status == TryOnStatus.success && state.result != null) {
            setState(() {
              _aiResult = state.result;
            });
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'AI analysis complete!'),
                backgroundColor: AppTheme.success.withOpacity(0.9),
              ),
            );
          }

          if (state.status == TryOnStatus.failure) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Try-on failed.'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == TryOnStatus.loading;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.unknown,
                  },
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.2, end: 0),

                      const SizedBox(height: 24),

                      // API Configuration Warning
                      if (!_geminiService.isConfigured)
                        _buildApiWarning().animate().fadeIn(
                          delay: 100.ms,
                          duration: 400.ms,
                        ),

                      if (!_geminiService.isConfigured)
                        const SizedBox(height: 16),

                      // Photo upload section with camera options
                      _buildPhotoSection()
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 24),

                      // Outfit selection
                      _buildOutfitSelection(
                        user.uid,
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                      const SizedBox(height: 24),

                      // Generate button
                      _buildGenerateButton(
                        user.uid,
                        isSubmitting,
                        context,
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                      // AI Result section
                      if (_aiResult != null) ...[
                        const SizedBox(height: 24),
                        _buildAIResult()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],

                      const SizedBox(height: 24),

                      // Recent try-ons
                      _buildRecentTryOns(
                        user.uid,
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI TRY-ON',
              style: AppTheme.headlineMedium.copyWith(letterSpacing: 3),
            ),
            const SizedBox(height: 4),
            Text(
              'Powered by Google Gemini',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neonPurple),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.neonPurple.withOpacity(
                    0.5 + 0.3 * _pulseController.value,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPurple.withOpacity(
                      0.3 * _pulseController.value,
                    ),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.neonPurple,
                size: 24,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildApiWarning() {
    return NeonCard(
      glowColor: AppTheme.warning,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Key Required',
                  style: AppTheme.titleMedium.copyWith(color: AppTheme.warning),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set your Gemini API key in lib/config/app_config.dart',
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return NeonCard(
      glowColor: _userPhoto != null ? AppTheme.neonGreen : AppTheme.neonPurple,
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: _userPhoto == null ? 280 : 240,
        child: _userPhoto == null
            ? _buildUploadSection()
            : _buildPhotoPreview(),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.neonPurple.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1,
              size: 36,
              color: AppTheme.neonPurple,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'CAPTURE YOUR LOOK',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.neonPurple,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Take a full-body photo for best AI styling results',
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Camera and Gallery buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Camera button
              _buildPhotoOptionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                color: AppTheme.neonPurple,
                onTap: _openCamera,
              ),
              const SizedBox(width: 16),
              // Gallery button
              _buildPhotoOptionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                color: AppTheme.neonCyan,
                onTap: _pickFromGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: kIsWeb && _webPhotoBytes != null
              ? Image.memory(_webPhotoBytes!, fit: BoxFit.cover)
              : Image.file(File(_userPhoto!.path), fit: BoxFit.cover),
        ),
        // Overlay gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.backgroundDark.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        // Action buttons
        Positioned(
          bottom: 16,
          right: 16,
          child: Row(
            children: [
              // Retake with camera
              _buildMiniActionButton(
                icon: Icons.camera_alt,
                color: AppTheme.neonPurple,
                onTap: _openCamera,
              ),
              const SizedBox(width: 8),
              // Pick from gallery
              _buildMiniActionButton(
                icon: Icons.photo_library,
                color: AppTheme.neonCyan,
                onTap: _pickFromGallery,
              ),
            ],
          ),
        ),
        // Success badge
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.backgroundDark,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Photo Ready',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.backgroundDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildOutfitSelection(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'SELECT OUTFIT',
          subtitle: 'Choose from your wardrobe',
          icon: Icons.checkroom,
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('users')
              .doc(uid)
              .collection('wardrobe')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CyberLoader(size: 30));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return NeonCard(
                glowColor: AppTheme.neonCyan,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.neonCyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add items to your wardrobe first to use AI Try-On',
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final name = data['name'] as String? ?? 'Item';
                  final imageUrl = data['imageUrl'] as String?;
                  final isSelected = _selectedItemId == doc.id;

                  return _buildOutfitCard(
                    id: doc.id,
                    name: name,
                    imageUrl: imageUrl,
                    isSelected: isSelected,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOutfitCard({
    required String id,
    required String name,
    required String? imageUrl,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItemId = id;
          _selectedItemName = name;
          _selectedItemImageUrl = imageUrl;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.neonPurple : AppTheme.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? AppTheme.neonGlow(AppTheme.neonPurple, blur: 15)
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl == null
                    ? Container(
                        color: AppTheme.surfaceLight,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppTheme.surfaceLight,
                          child: const Center(child: CyberLoader(size: 20)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.surfaceLight,
                          child: const Icon(Icons.error_outline),
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    name,
                    style: AppTheme.labelLarge.copyWith(
                      fontSize: 12,
                      color: isSelected
                          ? AppTheme.neonPurple
                          : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Selected',
                        style: AppTheme.labelLarge.copyWith(
                          fontSize: 9,
                          color: AppTheme.backgroundDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(String uid, bool isSubmitting, BuildContext blocContext) {
    final canGenerate = _userPhoto != null && _selectedItemId != null;

    return SizedBox(
      width: double.infinity,
      child: GradientButton(
        text: isSubmitting ? 'ANALYZING...' : 'GENERATE AI TRY-ON',
        icon: Icons.auto_awesome,
        gradient: const LinearGradient(
          colors: [AppTheme.neonPurple, AppTheme.neonPink],
        ),
        isLoading: isSubmitting,
        onPressed: canGenerate && !isSubmitting
            ? () => _submitTryOn(uid, blocContext)
            : null,
      ),
    );
  }

  Widget _buildAIResult() {
    final analysis = _aiResult?['analysis'] as Map<String, dynamic>?;
    final confidenceRating = analysis?['confidenceRating'] as int? ?? 8;
    final description = _aiResult?['description'] as String? ?? '';

    return Column(
      children: [
        // Confidence Score Card
        NeonCard(
          glowColor: AppTheme.neonGreen,
          padding: const EdgeInsets.all(20),
          animate: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.neonGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI STYLE ANALYSIS',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.neonGreen,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Confidence Rating
              _buildConfidenceRating(confidenceRating),

              const SizedBox(height: 20),

              // Analysis Badges
              _buildAnalysisBadges(analysis),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Detailed Analysis
        NeonCard(
          glowColor: AppTheme.neonPurple,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: AppTheme.neonPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'DETAILED ANALYSIS',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.neonPurple,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormattedAnalysis(description),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceRating(int rating) {
    final color = rating >= 8
        ? AppTheme.neonGreen
        : (rating >= 6 ? AppTheme.neonCyan : AppTheme.warning);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Style Match Score', style: AppTheme.bodyMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: rating / 10,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            '$rating/10',
            style: AppTheme.headlineMedium.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisBadges(Map<String, dynamic>? analysis) {
    if (analysis == null) return const SizedBox.shrink();

    final badges = <Widget>[];

    if (analysis['hasVisualization'] == true) {
      badges.add(
        _buildBadge('Visualization', Icons.visibility, AppTheme.neonCyan),
      );
    }
    if (analysis['hasFitAssessment'] == true) {
      badges.add(
        _buildBadge('Fit Analysis', Icons.straighten, AppTheme.neonPurple),
      );
    }
    if (analysis['hasColorAnalysis'] == true) {
      badges.add(_buildBadge('Color Match', Icons.palette, AppTheme.neonPink));
    }
    if (analysis['hasStylingTips'] == true) {
      badges.add(
        _buildBadge(
          'Styling Tips',
          Icons.tips_and_updates,
          AppTheme.neonOrange,
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: badges);
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.labelLarge.copyWith(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedAnalysis(String text) {
    // Split by sections and format
    final sections = text.split(RegExp(r'\n\n|\*\*'));
    final widgets = <Widget>[];

    for (var i = 0; i < sections.length; i++) {
      var section = sections[i].trim();
      if (section.isEmpty) continue;

      // Check if it's a header (numbered or starts with capital)
      if (section.contains(':') && section.length < 50) {
        // This is likely a section header
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              section.replaceAll('*', '').trim(),
              style: AppTheme.titleMedium.copyWith(color: AppTheme.neonCyan),
            ),
          ),
        );
      } else {
        // Regular content
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              section.replaceAll('*', '').trim(),
              style: AppTheme.bodyLarge,
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      return Text(text, style: AppTheme.bodyLarge);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRecentTryOns(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'RECENT TRY-ONS',
          subtitle: 'Your style history',
          icon: Icons.history,
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('users')
              .doc(uid)
              .collection('tryons')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CyberLoader(size: 30));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return NeonCard(
                glowColor: AppTheme.neonCyan,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppTheme.textMuted),
                    const SizedBox(width: 12),
                    Text('No try-on history yet', style: AppTheme.bodyMedium),
                  ],
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data();
                final status = data['status'] ?? 'pending';
                final itemName = data['wardrobeItemName'] ?? 'Item';
                final result = data['aiResult'] as String?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeonCard(
                    glowColor: _getStatusColor(status),
                    padding: const EdgeInsets.all(16),
                    onTap: result != null
                        ? () => _showFullResult(itemName, result)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(itemName, style: AppTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                result != null
                                    ? '${result.substring(0, result.length > 80 ? 80 : result.length)}...'
                                    : 'Status: ${status.toUpperCase()}',
                                style: AppTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (result != null)
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.textMuted,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showFullResult(String itemName, String result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.neonPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(itemName, style: AppTheme.headlineSmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFormattedAnalysis(result),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          title: 'Take Your Photo',
          subtitle: 'Stand in the frame for best results',
          showPoseGuide: true,
          onImageCaptured: (image) async {
            final bytes = kIsWeb ? await image.readAsBytes() : null;
            setState(() {
              _userPhoto = image;
              _webPhotoBytes = bytes;
              _aiResult = null;
            });
          },
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = kIsWeb ? await image.readAsBytes() : null;
      setState(() {
        _userPhoto = image;
        _webPhotoBytes = bytes;
        _aiResult = null;
      });
    }
  }

  Future<void> _submitTryOn(String uid, BuildContext blocContext) async {
    if (_userPhoto == null || _selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a photo and an outfit.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() {
      _aiResult = null;
    });

    final photoBytes = await _userPhoto!.readAsBytes();
    blocContext.read<TryOnBloc>().add(
      SubmitTryOnRequested(
        userId: uid,
        photoBytes: photoBytes,
        wardrobeItemId: _selectedItemId!,
        wardrobeItemName: _selectedItemName ?? 'clothing item',
        wardrobeItemImageUrl: _selectedItemImageUrl,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.neonGreen;
      case 'failed':
        return AppTheme.error;
      case 'processing':
        return AppTheme.neonPurple;
      default:
        return AppTheme.neonCyan;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'processing':
        return Icons.hourglass_top;
      default:
        return Icons.pending;
    }
  }
}
