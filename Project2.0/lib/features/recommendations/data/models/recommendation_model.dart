import '../../domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.title,
    required super.items,
    required super.tip,
  });

  factory RecommendationModel.fromMap(Map<String, dynamic> data) {
    return RecommendationModel(
      title: (data['title'] as String?) ?? 'Outfit',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      tip: (data['tip'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'items': items, 'tip': tip};
  }
}
