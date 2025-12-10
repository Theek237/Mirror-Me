import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mm/features/wardrobe/domain/entities/clothing_item.dart';

class ClothingItemModel extends ClothingItemEntity{
  const ClothingItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.imageUrl,
    required super.userId
  });

  //From Firebase Firestore DocumentSnapshot
  factory ClothingItemModel.fromSnapshot(DocumentSnapshot doc){
    final data = doc.data() as Map<String,dynamic>;
    return ClothingItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? ''
    );  
  }

  //To Firebase Firestore Map
  Map<String,dynamic> toJson(){
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}