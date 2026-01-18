import 'package:equatable/equatable.dart';

class FavoriteRecommendation extends Equatable {
  const FavoriteRecommendation({
    required this.id,
    required this.title,
    required this.items,
    required this.tip,
    required this.occasion,
  });

  final String id;
  final String title;
  final List<String> items;
  final String tip;
  final String occasion;

  @override
  List<Object?> get props => [id, title, items, tip, occasion];
}
