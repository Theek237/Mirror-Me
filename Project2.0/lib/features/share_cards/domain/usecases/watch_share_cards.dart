import '../entities/recommendation_card.dart';
import '../repositories/share_cards_repository.dart';

class WatchShareCards {
  const WatchShareCards(this._repository);

  final ShareCardsRepository _repository;

  Stream<List<RecommendationCard>> call(String uid, {int limit = 5}) {
    return _repository.watchRecent(uid, limit: limit);
  }
}
