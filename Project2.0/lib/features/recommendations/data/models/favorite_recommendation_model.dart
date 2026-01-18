import '../../domain/entities/favorite_recommendation.dart';

class FavoriteRecommendationModel extends FavoriteRecommendation {
  const FavoriteRecommendationModel({
    required super.id,
    required super.title,
    required super.items,
    required super.tip,
    required super.occasion,
  });

  factory FavoriteRecommendationModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return FavoriteRecommendationModel(
      id: id,
      title: (data['title'] as String?) ?? 'Outfit',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      tip: (data['tip'] as String?) ?? '',
      occasion: (data['occasion'] as String?) ?? 'Casual',
    );
  }
}
