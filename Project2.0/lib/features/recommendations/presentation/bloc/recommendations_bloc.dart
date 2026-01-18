import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_recommendation.dart';
import '../../domain/usecases/delete_favorite.dart';
import '../../domain/usecases/generate_recommendations.dart';
import '../../domain/usecases/save_favorite.dart';
import '../../domain/usecases/save_recommendations.dart';
import '../../domain/usecases/watch_favorites.dart';
import 'recommendations_event.dart';
import 'recommendations_state.dart';

class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc({
    required WatchFavorites watchFavorites,
    required GenerateRecommendations generateRecommendations,
    required SaveRecommendations saveRecommendations,
    required SaveFavorite saveFavorite,
    required DeleteFavorite deleteFavorite,
  }) : _watchFavorites = watchFavorites,
       _generateRecommendations = generateRecommendations,
       _saveRecommendations = saveRecommendations,
       _saveFavorite = saveFavorite,
       _deleteFavorite = deleteFavorite,
       super(RecommendationsState.initial()) {
    on<RecommendationsStarted>(_onStarted);
    on<OccasionSelected>(_onOccasionSelected);
    on<GenerateRequested>(_onGenerateRequested);
    on<RecommendationsUpdated>(_onRecommendationsUpdated);
    on<FavoritesUpdated>(_onFavoritesUpdated);
    on<FavoriteSaved>(_onFavoriteSaved);
    on<FavoriteDeleted>(_onFavoriteDeleted);
    on<RecommendationsFailed>(_onFailed);
    on<RecommendationsMessageCleared>(_onMessageCleared);
  }

  final WatchFavorites _watchFavorites;
  final GenerateRecommendations _generateRecommendations;
  final SaveRecommendations _saveRecommendations;
  final SaveFavorite _saveFavorite;
  final DeleteFavorite _deleteFavorite;

  StreamSubscription<List<FavoriteRecommendation>>? _favoritesSubscription;

  Future<void> _onStarted(
    RecommendationsStarted event,
    Emitter<RecommendationsState> emit,
  ) async {
    await _favoritesSubscription?.cancel();
    _favoritesSubscription = _watchFavorites(event.uid).listen(
      (favorites) => add(FavoritesUpdated(favorites: favorites)),
      onError: (error) => add(RecommendationsFailed(message: error.toString())),
    );
  }

  void _onOccasionSelected(
    OccasionSelected event,
    Emitter<RecommendationsState> emit,
  ) {
    emit(state.copyWith(selectedOccasion: event.occasion));
  }

  Future<void> _onGenerateRequested(
    GenerateRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    emit(state.copyWith(status: RecommendationsStatus.loading, message: null));
    try {
      final recommendations = await _generateRecommendations(
        uid: event.uid,
        occasion: state.selectedOccasion,
      );
      emit(
        state.copyWith(
          recommendations: recommendations,
          status: RecommendationsStatus.success,
        ),
      );
      await _saveRecommendations(
        uid: event.uid,
        occasion: state.selectedOccasion,
        recommendations: recommendations,
      );
      emit(state.copyWith(message: 'Recommendations generated!'));
    } catch (e) {
      final message = e.toString().contains('EMPTY_WARDROBE')
          ? 'Add items to your wardrobe first!'
          : 'Error: ${e.toString()}';
      emit(
        state.copyWith(status: RecommendationsStatus.failure, message: message),
      );
    }
  }

  void _onRecommendationsUpdated(
    RecommendationsUpdated event,
    Emitter<RecommendationsState> emit,
  ) {
    emit(state.copyWith(recommendations: event.recommendations));
  }

  void _onFavoritesUpdated(
    FavoritesUpdated event,
    Emitter<RecommendationsState> emit,
  ) {
    emit(state.copyWith(favorites: event.favorites));
  }

  Future<void> _onFavoriteSaved(
    FavoriteSaved event,
    Emitter<RecommendationsState> emit,
  ) async {
    await _saveFavorite(
      uid: event.uid,
      occasion: state.selectedOccasion,
      recommendation: event.recommendation,
    );
    emit(state.copyWith(message: 'Saved to favorites!'));
  }

  Future<void> _onFavoriteDeleted(
    FavoriteDeleted event,
    Emitter<RecommendationsState> emit,
  ) async {
    await _deleteFavorite(uid: event.uid, favoriteId: event.favoriteId);
  }

  void _onFailed(
    RecommendationsFailed event,
    Emitter<RecommendationsState> emit,
  ) {
    emit(
      state.copyWith(
        status: RecommendationsStatus.failure,
        message: event.message,
      ),
    );
  }

  void _onMessageCleared(
    RecommendationsMessageCleared event,
    Emitter<RecommendationsState> emit,
  ) {
    emit(state.copyWith(message: null));
  }

  @override
  Future<void> close() async {
    await _favoritesSubscription?.cancel();
    return super.close();
  }
}
