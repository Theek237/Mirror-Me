import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/image_storage_service.dart';

class TryOnRemoteDataSource {
  TryOnRemoteDataSource(this._firestore, this._geminiService);

  final FirebaseFirestore _firestore;
  final GeminiService _geminiService;

  Future<Map<String, dynamic>> submitTryOn({
    required String userId,
    required Uint8List photoBytes,
    required String wardrobeItemId,
    required String wardrobeItemName,
    String? wardrobeItemImageUrl,
  }) async {
    final result = await _geminiService.generateTryOnImage(
      userPhoto: photoBytes,
      clothingDescription: wardrobeItemName,
      clothingImageUrl: wardrobeItemImageUrl,
    );

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('tryons')
        .doc();

    // Upload original user photo
    final photoUrl = await ImageStorageService.uploadImageBytes(
      userId: userId,
      folder: 'tryons',
      fileName: '${docRef.id}_original.jpg',
      imageBytes: photoBytes,
    );

    // Upload AI generated image if available
    String? generatedImageUrl;
    final generatedBytes = result['generatedImageBytes'];
    if (generatedBytes != null && generatedBytes is Uint8List) {
      try {
        generatedImageUrl = await ImageStorageService.uploadImageBytes(
          userId: userId,
          folder: 'tryons',
          fileName: '${docRef.id}_generated.jpg',
          imageBytes: generatedBytes,
        );
        debugPrint('AI generated image saved: $generatedImageUrl');
      } catch (e) {
        debugPrint('Failed to save generated image: $e');
      }
    }

    await docRef.set({
      'photoUrl': photoUrl,
      'generatedImageUrl': generatedImageUrl,
      'hasGeneratedImage': result['hasGeneratedImage'] ?? false,
      'wardrobeItemId': wardrobeItemId,
      'wardrobeItemName': wardrobeItemName,
      'wardrobeItemImageUrl': wardrobeItemImageUrl,
      'status': result['success'] ? 'completed' : 'failed',
      'aiResult': result['description'],
      'analysis': result['analysis'],
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Return result with generated image URL
    return {...result, 'generatedImageUrl': generatedImageUrl};
  }
}
