import 'package:equatable/equatable.dart';

class RecommendationCard extends Equatable {
  const RecommendationCard({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<String> items;

  @override
  List<Object?> get props => [id, title, items];
}
