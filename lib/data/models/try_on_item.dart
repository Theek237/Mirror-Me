enum ClothingCategory { top, bottom, dress }

abstract class TryOnItem {
  final String itemId;
  final String name;
  final String imageUrl;
  final ClothingCategory category;

  TryOnItem({
    required this.itemId,
    required this.name,
    required this.imageUrl,
    required this.category,
  });

  Map<String,dynamic> toMap();
}