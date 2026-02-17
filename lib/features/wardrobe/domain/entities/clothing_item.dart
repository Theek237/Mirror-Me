import 'package:equatable/equatable.dart';

class ClothingItemEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String userId;

  const ClothingItemEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, name, category, imageUrl, userId];
}
