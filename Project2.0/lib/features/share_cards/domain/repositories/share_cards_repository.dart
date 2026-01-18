import '../entities/recommendation_card.dart';

abstract class ShareCardsRepository {
  Stream<List<RecommendationCard>> watchRecent(String uid, {int limit = 5});
}
