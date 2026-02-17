import 'package:mm/core/errors/exception.dart';
import 'package:mm/features/recommendations/data/models/recommendation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RecommendationSupabaseDataSource {
  /// Saves a recommendation to the database
  Future<RecommendationModel> saveRecommendation({
    required String userId,
    required String imageUrl,
    required String recommendationText,
    String? imageSource,
  });

  /// Gets all recommendations for a user
  Future<List<RecommendationModel>> getRecommendations(String userId);

  /// Deletes a recommendation
  Future<void> deleteRecommendation(String id);
}

class RecommendationSupabaseDataSourceImpl
    implements RecommendationSupabaseDataSource {
  final SupabaseClient supabaseClient;

  RecommendationSupabaseDataSourceImpl({required this.supabaseClient});

  @override
  Future<RecommendationModel> saveRecommendation({
    required String userId,
    required String imageUrl,
    required String recommendationText,
    String? imageSource,
  }) async {
    try {
      final response = await supabaseClient
          .from('recommendations')
          .insert(
            RecommendationModel.toInsertJson(
              userId: userId,
              imageUrl: imageUrl,
              recommendationText: recommendationText,
              imageSource: imageSource,
            ),
          )
          .select()
          .single();

      return RecommendationModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to save recommendation: $e');
    }
  }

  @override
  Future<List<RecommendationModel>> getRecommendations(String userId) async {
    try {
      final response = await supabaseClient
          .from('recommendations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RecommendationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get recommendations: $e');
    }
  }

  @override
  Future<void> deleteRecommendation(String id) async {
    try {
      await supabaseClient.from('recommendations').delete().eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Failed to delete recommendation: $e');
    }
  }
}
