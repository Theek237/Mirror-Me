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
        appBar: AppBar(title: const Text("My Wardrobe")),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
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
              child: const Icon(Icons.add),
            );
          },
        ),
        body: BlocBuilder<WardrobeBloc, WardrobeState>(
          builder: (context, state) {
            if (state is WardrobeLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WardrobeErrorState) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is WardrobeLoadedState) {
              if (state.clothingItems.isEmpty) {
                return const Center(
                  child: Text("No items yet. Add some clothes!"),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.clothingItems.length,
                itemBuilder: (context, index) {
                  final item = state.clothingItems[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const Center(child: Icon(Icons.image)),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                  context.read<WardrobeBloc>().add(
                                    WardrobeDeleteClothingItemEvent(
                                      userId: userId,
                                      itemId: item.id,
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: Text("Start adding clothes!"));
          },
        ),
      ),
    );
  }
}
