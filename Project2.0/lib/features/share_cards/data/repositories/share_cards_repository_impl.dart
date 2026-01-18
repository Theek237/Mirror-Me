import '../../domain/entities/recommendation_card.dart';
import '../../domain/repositories/share_cards_repository.dart';
import '../datasources/share_cards_remote_datasource.dart';

class ShareCardsRepositoryImpl implements ShareCardsRepository {
  ShareCardsRepositoryImpl(this._remote);

  final ShareCardsRemoteDataSource _remote;

  @override
  Stream<List<RecommendationCard>> watchRecent(String uid, {int limit = 5}) {
    return _remote.watchRecent(uid, limit: limit);
  }
}
