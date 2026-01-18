import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  }

  static bool get isInitialized => _isInitialized;
  static SupabaseClient? get client => _client;

  /// Upload image to Supabase Storage
  /// Returns the public URL of the uploaded image
  static Future<String?> uploadImage({
    required String bucket,
    required String path,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    if (!_isInitialized || _client == null) {
      debugPrint('Supabase not initialized');
      return null;
    }

    try {
      // Upload the image
      await _client!.storage.from(bucket).uploadBinary(
            path,
            imageBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      // Get the public URL
      final publicUrl = _client!.storage.from(bucket).getPublicUrl(path);
      debugPrint('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Failed to upload image: $e');
      return null;
    }
  }

  /// Delete image from Supabase Storage
  static Future<bool> deleteImage({
    required String bucket,
    required String path,
  }) async {
    if (!_isInitialized || _client == null) {
      debugPrint('Supabase not initialized');
      return false;
    }

    try {
      await _client!.storage.from(bucket).remove([path]);
      debugPrint('Image deleted successfully: $path');
      return true;
    } catch (e) {
      debugPrint('Failed to delete image: $e');
      return false;
    }
  }

  /// List images in a folder
  static Future<List<FileObject>> listImages({
    required String bucket,
    required String folder,
  }) async {
    if (!_isInitialized || _client == null) {
      debugPrint('Supabase not initialized');
      return [];
    }

    try {
      final files = await _client!.storage.from(bucket).list(path: folder);
      return files;
    } catch (e) {
      debugPrint('Failed to list images: $e');
      return [];
    }
  }
}
