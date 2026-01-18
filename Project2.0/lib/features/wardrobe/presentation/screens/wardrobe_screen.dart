import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mirror_me/core/di/injection.dart';
import 'package:mirror_me/core/services/image_storage_service.dart';
import 'package:mirror_me/core/services/local_wardrobe_cache.dart';
import 'package:mirror_me/features/wardrobe/domain/entities/wardrobe_item.dart';
import 'package:mirror_me/features/wardrobe/presentation/bloc/wardrobe_bloc.dart';
import 'package:mirror_me/features/wardrobe/presentation/bloc/wardrobe_event.dart';
import 'package:mirror_me/features/wardrobe/presentation/bloc/wardrobe_state.dart';
import 'package:mirror_me/theme/app_theme.dart';
import 'package:mirror_me/widgets/cyber_widgets.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final _auth = sl<FirebaseAuth>();
  final _firestore = sl<FirebaseFirestore>();
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to view your wardrobe.'));
    }

    return BlocProvider(
      create: (_) => sl<WardrobeBloc>()..add(WardrobeStarted(uid: user.uid)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(user.uid),

              // Category filter
              _buildCategoryFilter()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              // Wardrobe grid
              Expanded(child: _buildWardrobeGrid(user.uid)),
            ],
          ),
        ),
        floatingActionButton: _buildAddButton(user.uid),
      ),
    );
  }

  Widget _buildHeader(String uid) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MY WARDROBE',
                style: AppTheme.headlineMedium.copyWith(letterSpacing: 3),
              ),
              const SizedBox(height: 4),
              BlocBuilder<WardrobeBloc, WardrobeState>(
                builder: (context, state) {
                  final count = state.items.length;
                  return Text(
                    '$count items in your closet',
                    style: AppTheme.bodyMedium,
                  );
                },
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.checkroom,
              color: AppTheme.neonCyan,
              size: 24,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final isSelected = state.selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CyberChip(
                  label: category,
                  isSelected: isSelected,
                  selectedColor: AppTheme.neonCyan,
                  onTap: () {
                    context.read<WardrobeBloc>().add(
                          WardrobeCategorySelected(category: category),
                        );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWardrobeGrid(String uid) {
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        if (state.status == WardrobeStatus.loading) {
          return const Center(child: CyberLoader());
        }

        if (state.status == WardrobeStatus.failure) {
          return EmptyState(
            icon: Icons.warning_amber_rounded,
            title: 'Unable to load wardrobe',
            subtitle: state.errorMessage ?? 'Please try again later.',
            actionLabel: 'Retry',
            onAction: () =>
                context.read<WardrobeBloc>().add(WardrobeStarted(uid: uid)),
          );
        }

        if (state.filteredItems.isEmpty) {
          return EmptyState(
            icon: Icons.checkroom,
            title: 'Your wardrobe is empty',
            subtitle:
                'Add your first clothing item to get started with AI styling',
            actionLabel: 'Add Item',
            onAction: () => _showAddItemDialog(context, uid),
          );
        }

        final items = state.filteredItems;

        return AnimationLimiter(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: 2,
                duration: const Duration(milliseconds: 400),
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildWardrobeCard(items[index], uid),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWardrobeCard(WardrobeItem item, String uid) {
    return NeonCard(
      glowColor: _getCategoryColor(item.category),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      onTap: () => _showItemDetails(item, uid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl == null
                      ? Container(
                          color: AppTheme.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        )
                      : item.imageUrl!.startsWith('file://')
                          ? Image.file(
                              File(Uri.parse(item.imageUrl!).toFilePath()),
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.surfaceLight,
                                child: const Center(
                                  child: CyberLoader(size: 30),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.surfaceLight,
                                child: const Icon(Icons.error_outline),
                              ),
                            ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          item.category,
                        ).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.backgroundDark,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorFromName(item.color),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.color,
                      style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String uid) {
    return GestureDetector(
      onTap: () => _showAddItemDialog(context, uid),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.neonGlow(AppTheme.neonCyan, blur: 20),
        ),
        child: const Icon(
          Icons.add,
          color: AppTheme.backgroundDark,
          size: 28,
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: const Duration(seconds: 2),
        );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tops':
        return AppTheme.neonCyan;
      case 'Bottoms':
        return AppTheme.neonPurple;
      case 'Dresses':
        return AppTheme.neonPink;
      case 'Shoes':
        return AppTheme.neonOrange;
      case 'Outerwear':
        return AppTheme.neonBlue;
      case 'Accessories':
        return AppTheme.neonGreen;
      default:
        return AppTheme.neonCyan;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'neutral':
        return Colors.grey;
      case 'warm':
        return Colors.orange;
      case 'cool':
        return Colors.blue;
      case 'bright':
        return Colors.yellow;
      case 'pastel':
        return Colors.pink.shade200;
      case 'dark':
        return Colors.grey.shade800;
      default:
        return Colors.grey;
    }
  }

  void _showAddItemDialog(BuildContext context, String uid) {
    final nameController = TextEditingController();
    String category = 'Tops';
    String color = 'Neutral';
    XFile? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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

                  Text(
                    'ADD NEW ITEM',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.neonCyan,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name field
                  TextField(
                    controller: nameController,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: category,
                    dropdownColor: AppTheme.surfaceDark,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      'Tops',
                      'Bottoms',
                      'Dresses',
                      'Shoes',
                      'Outerwear',
                      'Accessories',
                    ].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => category = value ?? category),
                  ),
                  const SizedBox(height: 16),

                  // Color dropdown
                  DropdownButtonFormField<String>(
                    value: color,
                    dropdownColor: AppTheme.surfaceDark,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Color Palette',
                      prefixIcon: Icon(Icons.palette_outlined),
                    ),
                    items: const [
                      'Neutral',
                      'Warm',
                      'Cool',
                      'Bright',
                      'Pastel',
                      'Dark',
                    ].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => color = value ?? color),
                  ),
                  const SizedBox(height: 16),

                  // Photo picker
                  NeonCard(
                    glowColor: selectedImage != null
                        ? AppTheme.neonGreen
                        : AppTheme.neonCyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onTap: () async {
                      final image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() => selectedImage = image);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedImage == null
                              ? Icons.add_photo_alternate_outlined
                              : Icons.check_circle,
                          color: selectedImage != null
                              ? AppTheme.neonGreen
                              : AppTheme.neonCyan,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedImage == null
                              ? 'Add Photo'
                              : 'Photo Selected',
                          style: AppTheme.labelLarge.copyWith(
                            color: selectedImage != null
                                ? AppTheme.neonGreen
                                : AppTheme.neonCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'SAVE ITEM',
                      icon: Icons.save_outlined,
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        Navigator.pop(context);
                        await _addItem(
                          uid,
                          name,
                          category,
                          color,
                          selectedImage,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addItem(
    String uid,
    String name,
    String category,
    String color,
    XFile? image,
  ) async {
    final docRef =
        _firestore.collection('users').doc(uid).collection('wardrobe').doc();
    String? imageUrl;

    if (image != null) {
      // Use the unified ImageStorageService (supports both Firebase and Supabase)
      imageUrl = await ImageStorageService.uploadImage(
        userId: uid,
        folder: 'wardrobe',
        fileName: '${docRef.id}.jpg',
        imageFile: image,
      );

      if (imageUrl == null) {
        imageUrl = 'file://${image.path}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Image upload failed. Showing local image only.',
              ),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }

    final createdAt = DateTime.now();

    await LocalWardrobeCache.upsert(
      uid,
      WardrobeItem(
        id: docRef.id,
        name: name,
        category: category,
        color: color,
        createdAt: createdAt,
        imageUrl: imageUrl,
      ),
    );

    try {
      await docRef.set({
        'name': name,
        'category': category,
        'color': color,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Saved locally. Cloud sync failed (check connection).',
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added to wardrobe'),
          backgroundColor: AppTheme.success.withOpacity(0.9),
        ),
      );
    }
  }

  void _showItemDetails(WardrobeItem item, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(
                          item.category,
                        ).withOpacity(0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.checkroom,
                      color: _getCategoryColor(item.category),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppTheme.headlineSmall),
                        Text(
                          '${item.category} • ${item.color}',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: NeonCard(
                      glowColor: AppTheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onTap: () async {
                        await _firestore
                            .collection('users')
                            .doc(uid)
                            .collection('wardrobe')
                            .doc(item.id)
                            .delete();
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item deleted'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: AppTheme.labelLarge.copyWith(
                              color: AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
