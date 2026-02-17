import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:mm/core/theme/app_theme.dart';
import 'package:mm/features/tryon/presentation/bloc/tryon_bloc.dart';
import 'package:mm/features/gallery/data/models/user_image_model.dart';
import 'package:mm/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe_bloc/wardrobe_bloc.dart';

class TryOnPage extends StatefulWidget {
  final String userId;

  const TryOnPage({super.key, required this.userId});

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  UserImageModel? _selectedPose;
  ClothingItemModel? _selectedClothing;
  Uint8List? _generatedResult;
  bool _isSaved = false;
  bool _isSaving = false;
  String? _saveError;
  bool _isSavingToGallery = false;

  @override
  void initState() {
    super.initState();
    // Load gallery and wardrobe items
    context.read<GalleryBloc>().add(
      GalleryLoadImagesEvent(userId: widget.userId),
    );
    context.read<WardrobeBloc>().add(
      WardrobeLoadWardrobeItemsEvent(userId: widget.userId),
    );
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
    return null;
  }

  void _generateTryOn() async {
    if (_selectedPose == null || _selectedClothing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both a pose and clothing item'),
          backgroundColor: AppTheme.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Fetch image bytes
    final poseBytes = await _fetchImageBytes(_selectedPose!.imageUrl);
    final clothingBytes = await _fetchImageBytes(_selectedClothing!.imageUrl);

    if (poseBytes == null || clothingBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load images. Please try again.'),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      context.read<TryOnBloc>().add(
        TryOnGenerateEvent(
          poseImageBytes: poseBytes,
          clothingImageBytes: clothingBytes,
          poseImageUrl: _selectedPose!.imageUrl,
          clothingImageUrl: _selectedClothing!.imageUrl,
        ),
      );
    }
  }

  void _saveResult() {
    if (_generatedResult == null || _isSaved || _isSaving) return;

    context.read<TryOnBloc>().add(
      TryOnSaveResultEvent(
        userId: widget.userId,
        poseImageUrl: _selectedPose!.imageUrl,
        clothingImageUrl: _selectedClothing!.imageUrl,
        resultImageBytes: _generatedResult!,
      ),
    );
  }

  Future<void> _saveToGallery() async {
    if (_generatedResult == null || _isSavingToGallery) return;

    setState(() {
      _isSavingToGallery = true;
    });

    try {
      await Gal.putImageBytes(
        _generatedResult!,
        album: 'Mirror Me',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image saved to gallery!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save to gallery: $e'),
            backgroundColor: AppTheme.secondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingToGallery = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),
            // Content
            Expanded(
              child: BlocConsumer<TryOnBloc, TryOnState>(
                listener: (context, state) {
                  if (state is TryOnGeneratedState) {
                    setState(() {
                      _generatedResult = state.resultImageBytes;
                      _isSaved = false;
                      _isSaving = true;
                      _saveError = null;
                    });
                    // Auto-save to generated images collection
                    _saveResult();
                  } else if (state is TryOnSavedState) {
                    setState(() {
                      _isSaved = true;
                      _isSaving = false;
                      _saveError = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Result saved successfully!'),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else if (state is TryOnErrorState) {
                    // If we were auto-saving and it failed, record error but keep the image
                    if (_isSaving) {
                      setState(() {
                        _isSaving = false;
                        _saveError = state.message;
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.secondaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, tryOnState) {
                  if (tryOnState is TryOnGeneratingState) {
                    return _buildGeneratingView();
                  }

                  if (_generatedResult != null) {
                    return _buildResultView(tryOnState);
                  }

                  return _buildSelectionView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Virtual Try-On",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          if (_generatedResult != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _generatedResult = null;
                  _selectedPose = null;
                  _selectedClothing = null;
                  _isSaved = false;
                  _isSaving = false;
                  _saveError = null;
                });
                context.read<TryOnBloc>().add(const TryOnResetEvent());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 22,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_fix_high_rounded,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Creating your look...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "AI is working its magic",
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(TryOnState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Image
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(_generatedResult!, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 12),

          // Auto-save status indicator
          _buildSaveStatusIndicator(),

          const SizedBox(height: 16),

          // Source Images Preview
          Row(
            children: [
              Expanded(
                child: _buildSourcePreview(
                  label: "Pose",
                  imageUrl: _selectedPose?.imageUrl,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.add, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSourcePreview(
                  label: "Clothing",
                  imageUrl: _selectedClothing?.imageUrl,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _generatedResult = null;
                      _isSaved = false;
                      _isSaving = false;
                      _saveError = null;
                    });
                    context.read<TryOnBloc>().add(const TryOnResetEvent());
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text("Try Again"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSavingToGallery ? null : _saveToGallery,
                  icon: _isSavingToGallery
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, color: Colors.white),
                  label: Text(
                    _isSavingToGallery ? "Saving..." : "Save to Gallery",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveStatusIndicator() {
    if (_isSaving) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Saving to collection...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_saveError != null) {
      return GestureDetector(
        onTap: _saveResult,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 14, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                'Save failed. Tap to retry.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSaved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              'Saved to collection',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSourcePreview({required String label, String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : const Center(
                  child: Icon(Icons.image, color: AppTheme.textLight),
                ),
        ),
      ],
    );
  }

  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Select Pose
          _buildSectionHeader(
            step: "1",
            title: "Select Your Pose",
            subtitle: "Choose a photo from your gallery",
          ),
          const SizedBox(height: 12),
          _buildPoseSelector(),

          const SizedBox(height: 28),

          // Step 2: Select Clothing
          _buildSectionHeader(
            step: "2",
            title: "Select Clothing",
            subtitle: "Pick an item from your wardrobe",
          ),
          const SizedBox(height: 12),
          _buildClothingSelector(),

          const SizedBox(height: 32),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: (_selectedPose != null && _selectedClothing != null)
                  ? _generateTryOn
                  : null,
              icon: const Icon(
                Icons.auto_fix_high_rounded,
                color: Colors.white,
              ),
              label: const Text(
                "Generate Try-On",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Best Results Tip",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Use clear, well-lit photos for the best AI results",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String step,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoseSelector() {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        if (state is GalleryLoadingState) {
          return _buildLoadingGrid();
        }

        if (state is GalleryLoadedState) {
          if (state.images.isEmpty) {
            return _buildEmptyState(
              icon: Icons.photo_library_outlined,
              message: "No poses yet. Add photos to your gallery first.",
            );
          }

          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final image = state.images[index];
                final isSelected = _selectedPose?.id == image.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPose = image;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(
                      right: index < state.images.length - 1 ? 12 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.secondaryColor
                            : Colors.grey.shade200,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: image.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppTheme.accentColor,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              color: AppTheme.secondaryColor.withValues(
                                alpha: 0.3,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return _buildEmptyState(
          icon: Icons.photo_library_outlined,
          message: "Unable to load gallery",
        );
      },
    );
  }

  Widget _buildClothingSelector() {
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        if (state is WardrobeLoadingState) {
          return _buildLoadingGrid();
        }

        if (state is WardrobeLoadedState) {
          if (state.clothingItems.isEmpty) {
            return _buildEmptyState(
              icon: Icons.checkroom,
              message:
                  "No clothing items yet. Add items to your wardrobe first.",
            );
          }

          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.clothingItems.length,
              itemBuilder: (context, index) {
                final item = state.clothingItems[index];
                final isSelected = _selectedClothing?.id == item.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedClothing = item;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(
                      right: index < state.clothingItems.length - 1 ? 12 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.secondaryColor
                            : Colors.grey.shade200,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppTheme.accentColor,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              color: AppTheme.secondaryColor.withValues(
                                alpha: 0.3,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return _buildEmptyState(
          icon: Icons.checkroom,
          message: "Unable to load wardrobe",
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppTheme.textLight),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
