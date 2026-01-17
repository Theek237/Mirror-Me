import 'package:mm/features/recommendations/domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.userId,
    required super.imageUrl,
    required super.recommendationText,
    super.imageSource,
    required super.createdAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      recommendationText: json['recommendation_text'] as String,
      imageSource: json['image_source'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'recommendation_text': recommendationText,
      'image_source': imageSource,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String imageUrl,
    required String recommendationText,
    String? imageSource,
  }) {
    return {
      'user_id': userId,
      'image_url': imageUrl,
      'recommendation_text': recommendationText,
      'image_source': imageSource,
    };
  }
}
