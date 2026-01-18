// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mm/features/wardrobe/presentation/bloc/wardrobe%20bloc/wardrobe_bloc.dart';
// import 'package:mm/features/wardrobe/presentation/pages/add_cloth_page.dart';
// import 'package:mm/injection_container.dart';

// class WardrobePage extends StatelessWidget {
//   final String userId;
//   const WardrobePage({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           sl<WardrobeBloc>()
//             ..add(WardrobeLoadWardrobeItemsEvent(userId: userId)),
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Wardrobe Page')),
//         floatingActionButton: Builder(
//           builder: (context) {
//             return FloatingActionButton(
//               onPressed: () {
//                 final bloc = context.read<WardrobeBloc>();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => BlocProvider.value(
//                       value: bloc,
//                       child: AddClothPage(userId: userId),
//                     ),
//                   ),
//                 );
//               },
//               child: const Icon(Icons.add),
//             );
//           },
//         ),
//         body: BlocBuilder<WardrobeBloc, WardrobeState>(
//           builder: (context, state) {
//             if (state is WardrobeLoadingState) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is WardrobeErrorState) {
//               return Center(child: Text('Error: ${state.message}'));
//             } else if (state is WardrobeLoadedState) {
//               if (state.clothingItems.isEmpty) {
//                 return const Center(child: Text('No items in wardrobe.'));
//               }
//               return GridView.builder(
//                 padding: EdgeInsets.all(16),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.75,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: state.clothingItems.length,
//                 itemBuilder: (context, index) {
//                   final item = state.clothingItems[index];
//                   return Card(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: Image.network(
//                             item.imageUrl,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             item.name,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             }
//             return const Center(child: CircularProgressIndicator());
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/core/theme/app_theme.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe%20bloc/wardrobe_bloc.dart';
import '../../../../injection_container.dart';
import 'add_cloth_page.dart';

class WardrobePage extends StatelessWidget {
  final String userId;
  const WardrobePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<WardrobeBloc>()
            ..add(WardrobeLoadWardrobeItemsEvent(userId: userId)),
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
                        "My Wardrobe",
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
                            final bloc = context.read<WardrobeBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: bloc,
                                  child: AddClothPage(userId: userId),
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

              // Content
              Expanded(
                child: BlocBuilder<WardrobeBloc, WardrobeState>(
                  builder: (context, state) {
                    if (state is WardrobeLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    } else if (state is WardrobeErrorState) {
                      return _buildEmptyState(
                        icon: Icons.error_outline,
                        title: "Oops!",
                        subtitle: state.message,
                      );
                    } else if (state is WardrobeLoadedState) {
                      if (state.clothingItems.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.checkroom_outlined,
                          title: "Empty wardrobe",
                          subtitle: "Start adding your clothes",
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
                        itemCount: state.clothingItems.length,
                        itemBuilder: (context, index) {
                          final item = state.clothingItems[index];
                          return _buildClothingCard(
                            context,
                            imageUrl: item.imageUrl,
                            name: item.name,
                            category: item.category,
                            onDelete: () {
                              _showDeleteDialog(context, userId, item.id);
                            },
                          );
                        },
                      );
                    }
                    return _buildEmptyState(
                      icon: Icons.checkroom_outlined,
                      title: "Your wardrobe awaits",
                      subtitle: "Add your first clothing item",
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
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingCard(
    BuildContext context, {
    required String imageUrl,
    required String name,
    required String category,
    required VoidCallback onDelete,
  }) {
    return Container(
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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
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
                // Delete Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId, String itemId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Item?",
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "This will permanently remove this item from your wardrobe.",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WardrobeBloc>().add(
                WardrobeDeleteClothingItemEvent(userId: userId, itemId: itemId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
