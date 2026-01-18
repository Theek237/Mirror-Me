import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_recommendation.dart';
import '../../domain/entities/recommendation.dart';

enum RecommendationsStatus { initial, loading, success, failure }

class RecommendationsState extends Equatable {
  const RecommendationsState({
    required this.status,
    required this.selectedOccasion,
    required this.recommendations,
    required this.favorites,
    required this.occasions,
    this.message,
  });

  factory RecommendationsState.initial() {
    return const RecommendationsState(
      status: RecommendationsStatus.initial,
      selectedOccasion: 'Casual',
      recommendations: [],
      favorites: [],
      occasions: ['Casual', 'Work', 'Party', 'Date', 'Formal', 'Sport'],
      message: null,
    );
  }

  final RecommendationsStatus status;
  final String selectedOccasion;
  final List<Recommendation> recommendations;
  final List<FavoriteRecommendation> favorites;
  final List<String> occasions;
  final String? message;

  RecommendationsState copyWith({
    RecommendationsStatus? status,
    String? selectedOccasion,
    List<Recommendation>? recommendations,
    List<FavoriteRecommendation>? favorites,
    List<String>? occasions,
    String? message,
  }) {
    return RecommendationsState(
      status: status ?? this.status,
      selectedOccasion: selectedOccasion ?? this.selectedOccasion,
      recommendations: recommendations ?? this.recommendations,
      favorites: favorites ?? this.favorites,
      occasions: occasions ?? this.occasions,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedOccasion,
    recommendations,
    favorites,
    occasions,
    message,
  ];
}
