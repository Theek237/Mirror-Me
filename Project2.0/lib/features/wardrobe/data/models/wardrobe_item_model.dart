import '../../domain/entities/wardrobe_item.dart';

class WardrobeItemModel extends WardrobeItem {
  const WardrobeItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.color,
    required super.createdAt,
    super.imageUrl,
  });

  factory WardrobeItemModel.fromMap(String id, Map<String, dynamic> data) {
    return WardrobeItemModel(
      id: id,
      name: (data['name'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'Other',
      color: (data['color'] as String?) ?? 'Neutral',
      imageUrl: data['imageUrl'] as String?,
      createdAt:
          DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'color': color,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
