import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_recommendation.dart';
import '../../domain/entities/recommendation.dart';

abstract class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class RecommendationsStarted extends RecommendationsEvent {
  const RecommendationsStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class OccasionSelected extends RecommendationsEvent {
  const OccasionSelected({required this.occasion});

  final String occasion;

  @override
  List<Object?> get props => [occasion];
}

class GenerateRequested extends RecommendationsEvent {
  const GenerateRequested({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class RecommendationsUpdated extends RecommendationsEvent {
  const RecommendationsUpdated({required this.recommendations});

  final List<Recommendation> recommendations;

  @override
  List<Object?> get props => [recommendations];
}

class FavoritesUpdated extends RecommendationsEvent {
  const FavoritesUpdated({required this.favorites});

  final List<FavoriteRecommendation> favorites;

  @override
  List<Object?> get props => [favorites];
}

class FavoriteSaved extends RecommendationsEvent {
  const FavoriteSaved({required this.uid, required this.recommendation});

  final String uid;
  final Recommendation recommendation;

  @override
  List<Object?> get props => [uid, recommendation];
}

class FavoriteDeleted extends RecommendationsEvent {
  const FavoriteDeleted({required this.uid, required this.favoriteId});

  final String uid;
  final String favoriteId;

  @override
  List<Object?> get props => [uid, favoriteId];
}

class RecommendationsFailed extends RecommendationsEvent {
  const RecommendationsFailed({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class RecommendationsMessageCleared extends RecommendationsEvent {
  const RecommendationsMessageCleared();
}
