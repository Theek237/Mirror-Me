import 'package:equatable/equatable.dart';

class WardrobeItem extends Equatable {
  const WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String color;
  final String? imageUrl;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, category, color, imageUrl, createdAt];
}
