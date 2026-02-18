import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mm/core/errors/exception.dart';
import 'package:mm/features/tryon/data/models/tryon_result_model.dart';

abstract class TryOnRemoteDataSource {
  /// Saves the try-on result image to storage and metadata to database
  Future<TryOnResultModel> saveTryOnResult({
    required String userId,
    required String poseImageUrl,
    required String clothingImageUrl,
    required Uint8List resultImageBytes,
    String? prompt,
  });

  /// Gets all try-on results for a user
  Future<List<TryOnResultModel>> getTryOnResults(String userId);

  /// Gets favorite try-on results for a user
  Future<List<TryOnResultModel>> getFavoriteTryOnResults(String userId);

  /// Toggles favorite status for a try-on result
  Future<TryOnResultModel> toggleFavorite(String resultId, bool isFavorite);

  /// Deletes a try-on result
  Future<void> deleteTryOnResult(String resultId);
}

class TryOnRemoteDataSourceImpl implements TryOnRemoteDataSource {
  final SupabaseClient supabaseClient;
  final _uuid = const Uuid();

  TryOnRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<TryOnResultModel> saveTryOnResult({
    required String userId,
    required String poseImageUrl,
    required String clothingImageUrl,
    required Uint8List resultImageBytes,
    String? prompt,
  }) async {
    try {
      // Generate unique filename
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = 'tryon_results/$userId/$fileName';

      // Upload result image to storage
      await supabaseClient.storage
          .from('tryon')
          .uploadBinary(
            filePath,
            resultImageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final resultImageUrl = supabaseClient.storage
          .from('tryon')
          .getPublicUrl(filePath);

      // Save metadata to database
      final response = await supabaseClient
          .from('tryon_results')
          .insert({
            'user_id': userId,
            'user_image_url': poseImageUrl,
            'cloth_image_url': clothingImageUrl,
            'result_image_url': resultImageUrl,
          })
          .select()
          .single();

      return TryOnResultModel.fromJson(response);
    } on StorageException catch (e) {
      throw ServerException(message: 'Storage error: ${e.message}');
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to save try-on result: $e');
    }
  }

  @override
  Future<List<TryOnResultModel>> getTryOnResults(String userId) async {
    try {
      final response = await supabaseClient
          .from('tryon_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TryOnResultModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch try-on results: $e');
    }
  }

  @override
  Future<void> deleteTryOnResult(String resultId) async {
    try {
      // First get the result to get the image URL
      final result = await supabaseClient
          .from('tryon_results')
          .select()
          .eq('id', resultId)
          .single();

      // Extract file path from URL
      final resultImageUrl = result['result_image_url'] as String;
      final uri = Uri.parse(resultImageUrl);
      final pathSegments = uri.pathSegments;
      // Find index of 'tryon' bucket and get path after it
      final bucketIndex = pathSegments.indexOf('tryon');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        // Delete from storage
        await supabaseClient.storage.from('tryon').remove([filePath]);
      }

      // Delete from database
      await supabaseClient.from('tryon_results').delete().eq('id', resultId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } on StorageException catch (e) {
      throw ServerException(message: 'Storage error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to delete try-on result: $e');
    }
  }

  @override
  Future<List<TryOnResultModel>> getFavoriteTryOnResults(String userId) async {
    try {
      final response = await supabaseClient
          .from('tryon_results')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TryOnResultModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to fetch favorite results: $e');
    }
  }

  @override
  Future<TryOnResultModel> toggleFavorite(
    String resultId,
    bool isFavorite,
  ) async {
    try {
      final response = await supabaseClient
          .from('tryon_results')
          .update({'is_favorite': isFavorite})
          .eq('id', resultId)
          .select()
          .single();

      return TryOnResultModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Database error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to update favorite status: $e');
    }
  }
}
