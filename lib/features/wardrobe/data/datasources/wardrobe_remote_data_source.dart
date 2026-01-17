import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mm/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:uuid/uuid.dart';

abstract class WardrobeRemoteDataSource {
  Future<List<ClothingItemModel>> getClothingItems(String userId);
  Future<void> addClothingItem(
    String userId,
    String name,
    String category,
    File imageFile,
  );
  Future<void> deleteClothingItem(String userId, String itemId);
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  final SupabaseClient supabaseClient;

  WardrobeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> addClothingItem(
    String userId,
    String name,
    String category,
    File imageFile,
  ) async {
    try {
      final String itemId = const Uuid().v4();
      final String fileName = '$itemId.${imageFile.path.split('.').last}';
      final String storagePath = 'user_cloths/$userId/$fileName';

      // Upload image to Supabase Storage
      await supabaseClient.storage
          .from('wardrobe')
          .upload(storagePath, imageFile);

      // Get the public URL for the uploaded image
      final String imageUrl = supabaseClient.storage
          .from('wardrobe')
          .getPublicUrl(storagePath);

      // Create the clothing item model
      final model = ClothingItemModel(
        id: itemId,
        name: name,
        category: category,
        imageUrl: imageUrl,
        userId: userId,
      );

      // Insert into wardrobe table
      await supabaseClient.from('wardrobe').insert(model.toJson());
    } catch (e) {
      throw Exception('Error adding clothing item: $e');
    }
  }

  @override
  Future<void> deleteClothingItem(String userId, String itemId) async {
    // First get the item to find the storage path
    final response = await supabaseClient
        .from('wardrobe')
        .select()
        .eq('id', itemId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      final imageUrl = response['image_url'] as String;
      // Extract storage path from URL
      final storagePath = imageUrl.split('/wardrobe/').last;

      // Delete from storage
      await supabaseClient.storage.from('wardrobe').remove([storagePath]);
    }

    // Delete from database
    await supabaseClient
        .from('wardrobe')
        .delete()
        .eq('id', itemId)
        .eq('user_id', userId);
  }

  @override
  Future<List<ClothingItemModel>> getClothingItems(String userId) async {
    final response = await supabaseClient
        .from('wardrobe')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => ClothingItemModel.fromJson(item))
        .toList();
  }
}
