import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';
import 'supabase_service.dart';

enum StorageProvider { firebase, supabase }

class ImageStorageService {
  static StorageProvider _provider = StorageProvider.firebase;

  static void setProvider(StorageProvider provider) {
    _provider = provider;
  }

  static StorageProvider get currentProvider => _provider;

  /// Upload image from XFile
  /// Returns the public URL of the uploaded image
  static Future<String?> uploadImage({
    required String userId,
    required String folder,
    required String fileName,
    required XFile imageFile,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return uploadImageBytes(
        userId: userId,
        folder: folder,
        fileName: fileName,
        imageBytes: bytes,
      );
    } catch (e) {
      debugPrint('Failed to read image file: $e');
      return null;
    }
  }

  /// Upload image from bytes
  /// Returns the public URL of the uploaded image
  static Future<String?> uploadImageBytes({
    required String userId,
    required String folder,
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    if (_provider == StorageProvider.supabase &&
        SupabaseService.isInitialized) {
      return _uploadToSupabase(
        userId: userId,
        folder: folder,
        fileName: fileName,
        imageBytes: imageBytes,
      );
    } else {
      return _uploadToFirebase(
        userId: userId,
        folder: folder,
        fileName: fileName,
        imageBytes: imageBytes,
      );
    }
  }

  /// Upload to Supabase Storage
  static Future<String?> _uploadToSupabase({
    required String userId,
    required String folder,
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    final bucket = _getBucketForFolder(folder);
    final path = '$userId/$folder/$fileName';

    return SupabaseService.uploadImage(
      bucket: bucket,
      path: path,
      imageBytes: imageBytes,
    );
  }

  /// Upload to Firebase Storage
  static Future<String?> _uploadToFirebase({
    required String userId,
    required String folder,
    required String fileName,
    required Uint8List imageBytes,
  }) async {
    Future<String?> attemptUpload(FirebaseStorage storage) async {
      try {
        final ref = storage.ref('users/$userId/$folder/$fileName');
        debugPrint('Attempting Firebase upload to: users/$userId/$folder/$fileName');
        
        final uploadTask = ref.putData(
          imageBytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
            },
          ),
        );

        // Wait for upload to complete
        final snapshot = await uploadTask;
        debugPrint('Upload state: ${snapshot.state}');
        
        if (snapshot.state == TaskState.success) {
          final url = await ref.getDownloadURL();
          debugPrint('✅ Firebase upload successful: $url');
          return url;
        } else {
          debugPrint('❌ Upload failed with state: ${snapshot.state}');
          return null;
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Firebase upload error: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    }

    // Try default bucket first
    try {
      debugPrint('🔄 Trying default Firebase Storage bucket...');
      return await attemptUpload(FirebaseStorage.instance);
    } catch (e) {
      debugPrint('⚠️ Default bucket failed: $e');
    }

    // Try fallback bucket with project ID
    try {
      final projectId = Firebase.app().options.projectId;
      if (projectId.isNotEmpty) {
        debugPrint('🔄 Trying fallback bucket: gs://$projectId.appspot.com');
        final fallbackStorage = FirebaseStorage.instanceFor(
          bucket: 'gs://$projectId.appspot.com',
        );
        return await attemptUpload(fallbackStorage);
      }
    } catch (e) {
      debugPrint('⚠️ Fallback bucket failed: $e');
    }

    debugPrint('❌ All Firebase upload attempts failed');
    return null;
  }

  /// Upload from File (non-web platforms)
  static Future<String?> uploadFile({
    required String userId,
    required String folder,
    required String fileName,
    required File file,
  }) async {
    if (kIsWeb) {
      debugPrint(
          'File upload not supported on web, use uploadImageBytes instead');
      return null;
    }

    try {
      final bytes = await file.readAsBytes();
      return uploadImageBytes(
        userId: userId,
        folder: folder,
        fileName: fileName,
        imageBytes: bytes,
      );
    } catch (e) {
      debugPrint('Failed to read file: $e');
      return null;
    }
  }

  /// Delete image
  static Future<bool> deleteImage({
    required String userId,
    required String folder,
    required String fileName,
  }) async {
    if (_provider == StorageProvider.supabase &&
        SupabaseService.isInitialized) {
      final bucket = _getBucketForFolder(folder);
      final path = '$userId/$folder/$fileName';
      return SupabaseService.deleteImage(bucket: bucket, path: path);
    } else {
      try {
        final storage = FirebaseStorage.instance;
        final ref = storage.ref('users/$userId/$folder/$fileName');
        await ref.delete();
        return true;
      } catch (e) {
        debugPrint('Failed to delete from Firebase: $e');
        return false;
      }
    }
  }

  /// Get the Supabase bucket name for a folder
  static String _getBucketForFolder(String folder) {
    switch (folder) {
      case 'wardrobe':
        return AppConfig.wardrobeBucket;
      case 'tryons':
        return AppConfig.tryonBucket;
      case 'profiles':
        return AppConfig.profileBucket;
      default:
        return AppConfig.wardrobeBucket;
    }
  }
}
