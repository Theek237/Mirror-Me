import '../entities/tryon_history_item.dart';
import '../repositories/tryon_history_repository.dart';

class WatchTryOnHistory {
  const WatchTryOnHistory(this._repository);

  final TryOnHistoryRepository _repository;

  Stream<List<TryOnHistoryItem>> call(String uid) {
    return _repository.watchHistory(uid);
  }
}
