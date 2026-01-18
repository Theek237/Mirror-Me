import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/core/theme/app_theme.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:mm/features/gallery/presentation/pages/add_image_page.dart';
import 'package:mm/features/gallery/presentation/pages/image_detail_page.dart';
import 'package:mm/injection_container.dart';

class GalleryPage extends StatelessWidget {
  final String userId;
  const GalleryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<GalleryBloc>()..add(GalleryLoadImagesEvent(userId: userId)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
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
                        "My Poses",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            final bloc = context.read<GalleryBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: bloc,
                                  child: AddImagePage(userId: userId),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Photos for virtual try-on",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: BlocBuilder<GalleryBloc, GalleryState>(
                  builder: (context, state) {
                    if (state is GalleryLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    } else if (state is GalleryErrorState) {
                      return _buildEmptyState(
                        icon: Icons.error_outline,
                        title: "Oops!",
                        subtitle: state.message,
                        actionLabel: "Try Again",
                        onAction: () {
                          context.read<GalleryBloc>().add(
                            GalleryLoadImagesEvent(userId: userId),
                          );
                        },
                      );
                    } else if (state is GalleryLoadedState) {
                      if (state.images.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.person_outline,
                          title: "No poses yet",
                          subtitle: "Add photos of yourself for virtual try-on",
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: state.images.length,
                        itemBuilder: (context, index) {
                          final image = state.images[index];
                          return _buildImageCard(context, image, userId);
                        },
                      );
                    }
                    return _buildEmptyState(
                      icon: Icons.person_outline,
                      title: "Your gallery awaits",
                      subtitle: "Add your first pose photo",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 48, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, dynamic image, String userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<GalleryBloc>(),
              child: ImageDetailPage(image: image, userId: userId),
            ),
          ),
        );
      },
      child: Hero(
        tag: 'image_${image.id}',
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.accentColor,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppTheme.textLight,
                          size: 32,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.accentColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppTheme.textLight,
                          size: 32,
                        ),
                      ),
                    ),
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
                      image.poseName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (image.description != null &&
                        image.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        image.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
