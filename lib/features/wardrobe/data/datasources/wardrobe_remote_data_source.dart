import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:mm/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:uuid/uuid.dart';

abstract class WardrobeRemoteDataSource {
  Future<List<ClothingItemModel>> getClothingItems(String userId);
  Future<void> addClothingItem(String userId, String name, String category, File imageFile);
  Future<void> deleteClothingItem(String userId, String itemId);
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource{
  final FirebaseFirestore firestore;
  final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  ));

  final String cloudName = 'duoqffei6';
  final String uploadPreset = 'ai_wardrobe_preset';

  WardrobeRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<void> addClothingItem(String userId, String name, String category, File imageFile) async {
    try{
      String fileName = imageFile.path.split('/').last;
      
      // Read file as bytes to avoid potential file lock/access issues during upload
      final bytes = await imageFile.readAsBytes();
      
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
        "upload_preset": uploadPreset,
        "folder": "user_cloths/$userId",
      });

      Response response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if(response.statusCode == 200){
        String imageUrl = response.data['secure_url'];
        
        final String itemId = const Uuid().v4();
        final model = ClothingItemModel(id: itemId, name: name, category: category, imageUrl: imageUrl, userId: userId);

        await firestore.collection('users').doc(userId).collection('wardrobe').doc(itemId).set(model.toJson());

      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e){
      throw Exception('Error adding clothing item: $e');
    }
  }

  @override
  Future<void> deleteClothingItem(String userId, String itemId) async {
    await firestore
      .collection('users')
      .doc(userId)
      .collection('wardrobe')
      .doc(itemId)
      .delete();
  }

  @override
  Future<List<ClothingItemModel>> getClothingItems(String userId) async {
    final querySnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('wardrobe')
      .orderBy('createdAt', descending: true)
      .get();

    return querySnapshot.docs
      .map((doc) => ClothingItemModel.fromSnapshot(doc),)
      .toList();
  }

}