import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mm/core/theme/app_theme.dart';
import 'package:mm/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe_bloc/wardrobe_bloc.dart';
import 'package:mm/features/tryon/presentation/bloc/tryon_bloc.dart';

class RecommendationsPage extends StatefulWidget {
  final String userId;

  const RecommendationsPage({super.key, required this.userId});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageUrl;
  String? _generatedRecommendation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load data from all sources
    context.read<GalleryBloc>().add(
      GalleryLoadImagesEvent(userId: widget.userId),
    );
    context.read<WardrobeBloc>().add(
      WardrobeLoadWardrobeItemsEvent(userId: widget.userId),
    );
    context.read<TryOnBloc>().add(TryOnLoadResultsEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageUrl = null;
      });
    }
  }

  Future<void> _selectFromUrl(String url, String source) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _selectedImageBytes = response.bodyBytes;
          _selectedImageUrl = url;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load image: $e'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    }
  }

  void _generateRecommendation() {
    if (_selectedImageBytes != null) {
      context.read<RecommendationBloc>().add(
        RecommendationGenerateEvent(imageBytes: _selectedImageBytes!),
      );
    }
  }

  void _reset() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageUrl = null;
      _generatedRecommendation = null;
    });
    context.read<RecommendationBloc>().add(const RecommendationResetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: BlocConsumer<RecommendationBloc, RecommendationState>(
                listener: (context, state) {
                  if (state is RecommendationGeneratedState) {
                    setState(() {
                      _generatedRecommendation = state.recommendationText;
                    });
                  } else if (state is RecommendationErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is RecommendationGeneratingState) {
                    return _buildGeneratingView();
                  }

                  if (_generatedRecommendation != null) {
                    return _buildResultView();
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
              "AI Style Advisor",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          if (_generatedRecommendation != null)
            GestureDetector(
              onTap: _reset,
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
              Icons.auto_awesome,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Analyzing your outfit...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "AI is crafting personalized recommendations",
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

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Image Preview
          if (_selectedImageBytes != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
              ),
            ),

          const SizedBox(height: 24),

          // Recommendation Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.style,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Style Recommendations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MarkdownBody(
                  data: _generatedRecommendation!,
                  styleSheet: MarkdownStyleSheet(
                    h2: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                    p: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    listBullet: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Another Outfit"),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    return Column(
      children: [
        // Image Preview or Placeholder
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _selectedImageBytes != null
                  ? AppTheme.secondaryColor
                  : Colors.grey.shade200,
              width: _selectedImageBytes != null ? 2 : 1,
            ),
          ),
          child: _selectedImageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageBytes = null;
                              _selectedImageUrl = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Select an image to analyze",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 16),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "Upload"),
              Tab(text: "Gallery"),
              Tab(text: "Wardrobe"),
              Tab(text: "Try-Ons"),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUploadTab(),
              _buildGalleryTab(),
              _buildWardrobeTab(),
              _buildTryOnTab(),
            ],
          ),
        ),

        // Generate Button
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _selectedImageBytes != null
                  ? _generateRecommendation
                  : null,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text(
                "Get AI Recommendations",
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
        ),
      ],
    );
  }

  Widget _buildUploadTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Upload from Device",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Choose a photo from your gallery",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        if (state is GalleryLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GalleryLoadedState) {
          if (state.images.isEmpty) {
            return _buildEmptyState("No photos in your gallery yet");
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.images.length,
            itemBuilder: (context, index) {
              final image = state.images[index];
              final isSelected = _selectedImageUrl == image.imageUrl;

              return GestureDetector(
                onTap: () => _selectFromUrl(image.imageUrl, 'gallery'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondaryColor
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: image.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        }

        return _buildEmptyState("Failed to load gallery");
      },
    );
  }

  Widget _buildWardrobeTab() {
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        if (state is WardrobeLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WardrobeLoadedState) {
          if (state.clothingItems.isEmpty) {
            return _buildEmptyState("No items in your wardrobe yet");
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.clothingItems.length,
            itemBuilder: (context, index) {
              final item = state.clothingItems[index];
              final isSelected = _selectedImageUrl == item.imageUrl;

              return GestureDetector(
                onTap: () => _selectFromUrl(item.imageUrl, 'wardrobe'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondaryColor
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        }

        return _buildEmptyState("Failed to load wardrobe");
      },
    );
  }

  Widget _buildTryOnTab() {
    return BlocBuilder<TryOnBloc, TryOnState>(
      builder: (context, state) {
        if (state is TryOnLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TryOnResultsLoadedState) {
          if (state.results.isEmpty) {
            return _buildEmptyState("No try-on results yet");
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final result = state.results[index];
              final isSelected = _selectedImageUrl == result.resultImageUrl;

              return GestureDetector(
                onTap: () => _selectFromUrl(result.resultImageUrl, 'tryon'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondaryColor
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: result.resultImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        }

        return _buildEmptyState("No try-on results available");
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
