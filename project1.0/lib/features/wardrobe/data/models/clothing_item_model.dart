import 'package:mm/features/wardrobe/domain/entities/clothing_item.dart';

class ClothingItemModel extends ClothingItemEntity {
  const ClothingItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.imageUrl,
    required super.userId,
  });

  // From Supabase row (Map)
  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  // To Supabase Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image_url': imageUrl,
      'user_id': userId,
    };
  }
}
