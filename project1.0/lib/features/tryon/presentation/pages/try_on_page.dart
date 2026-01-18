// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mm/features/tryon/presentation/bloc/try_on_bloc.dart';

// class TryOnPage extends StatelessWidget {
//   const TryOnPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Virtual Try-On'),
//       ),
//       body: BlocBuilder<TryOnBloc, TryOnState>(
//         builder: (context, state) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildImagePlaceholder('Your Image'),
//                     _buildImagePlaceholder('Clothing Item'),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 if (state is TryOnLoading)
//                   const CircularProgressIndicator()
//                 else if (state is TryOnLoaded)
//                   Image.network(state.imageUrl)
//                 else if (state is TryOnError)
//                   Text(
//                     state.message,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 const Spacer(),
//                 ElevatedButton(
//                   onPressed: () {
//                     context.read<TryOnBloc>().add(
//                           const GenerateImageEvent(
//                             userId: 'test_user',
//                             userImage: 'user_image_url',
//                             clothImage: 'cloth_image_url',
//                           ),
//                         );
//                   },
//                   child: const Text('Generate'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildImagePlaceholder(String title) {
//     return Column(
//       children: [
//         Text(title),
//         const SizedBox(height: 8),
//         Container(
//           width: 150,
//           height: 200,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.image, size: 50, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }
