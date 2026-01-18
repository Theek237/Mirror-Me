import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mm/features/gallery/data/models/user_image_model.dart';
import 'package:uuid/uuid.dart';

abstract class GalleryRemoteDataSource {
  Future<List<UserImageModel>> getUserImages(String userId);
  Future<void> addUserImage(
    String userId,
    String poseName,
    String? description,
    File imageFile,
  );
  Future<void> deleteUserImage(String userId, String imageId);
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  final SupabaseClient supabaseClient;

  GalleryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<UserImageModel>> getUserImages(String userId) async {
    debugPrint('GalleryDataSource: Fetching user images for $userId');
    final response = await supabaseClient
        .from('user_images')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => UserImageModel.fromJson(item))
        .toList();
  }

  @override
  Future<void> addUserImage(
    String userId,
    String poseName,
    String? description,
    File imageFile,
  ) async {
    debugPrint('GalleryDataSource: Adding user image...');
    try {
      final String imageId = const Uuid().v4();
      final String fileName = '$imageId.${imageFile.path.split('.').last}';
      final String storagePath = 'user_poses/$userId/$fileName';

      // Upload image to Supabase Storage
      await supabaseClient.storage
          .from('gallery')
          .upload(storagePath, imageFile);

      // Get the public URL for the uploaded image
      final String imageUrl = supabaseClient.storage
          .from('gallery')
          .getPublicUrl(storagePath);

      // Create the user image model
      final model = UserImageModel(
        id: imageId,
        userId: userId,
        imageUrl: imageUrl,
        poseName: poseName,
        description: description,
        createdAt: DateTime.now(),
      );

      // Insert into user_images table
      await supabaseClient.from('user_images').insert(model.toJson());
      debugPrint('GalleryDataSource: User image added successfully');
    } catch (e) {
      debugPrint('GalleryDataSource: Error adding user image - $e');
      throw Exception('Error adding user image: $e');
    }
  }

  @override
  Future<void> deleteUserImage(String userId, String imageId) async {
    debugPrint('GalleryDataSource: Deleting user image $imageId');
    // First get the item to find the storage path
    final response = await supabaseClient
        .from('user_images')
        .select()
        .eq('id', imageId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      final imageUrl = response['image_url'] as String;
      // Extract storage path from URL
      final storagePath = imageUrl.split('/gallery/').last;

      // Delete from storage
      await supabaseClient.storage.from('gallery').remove([storagePath]);
    }

    // Delete from database
    await supabaseClient
        .from('user_images')
        .delete()
        .eq('id', imageId)
        .eq('user_id', userId);

    debugPrint('GalleryDataSource: User image deleted successfully');
  }
}
