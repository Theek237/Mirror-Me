import 'package:mm/data/models/try_on_item.dart';

class UserClothingItem extends TryOnItem{
  final String userId;
  final String color;

  UserClothingItem({
    required String itemId,
    required String name,
    required String imageUrl,
    required ClothingCategory category,
    required this.userId,
    required this.color,
  }) : super(
          itemId: itemId,
          name: name,
          imageUrl: imageUrl,
          category: category,
        );
        
  @override
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last,
      'userId': userId,
      'color': color,
    };
  }

  factory UserClothingItem.fromMap(Map<String, dynamic> map) {
    return UserClothingItem(
      itemId: map['itemId'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      category: ClothingCategory.values.firstWhere((e) => e.toString() == map['category'], orElse: () => ClothingCategory.top),
      userId: map['userId'],
      color: map['color'] ?? 'Unknown',
    );
  }

}