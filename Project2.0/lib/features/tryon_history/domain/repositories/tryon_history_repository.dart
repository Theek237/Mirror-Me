import '../entities/tryon_history_item.dart';

abstract class TryOnHistoryRepository {
  Stream<List<TryOnHistoryItem>> watchHistory(String uid);
}
