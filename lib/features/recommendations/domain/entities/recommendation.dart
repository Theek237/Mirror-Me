import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String recommendationText;
  final String? imageSource; // 'gallery', 'wardrobe', 'tryon', 'upload'
  final DateTime createdAt;

  const Recommendation({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.recommendationText,
    this.imageSource,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    imageUrl,
    recommendationText,
    imageSource,
    createdAt,
  ];
}
