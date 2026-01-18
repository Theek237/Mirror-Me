import '../../domain/entities/tryon_history_item.dart';
import '../../domain/repositories/tryon_history_repository.dart';
import '../datasources/tryon_history_remote_datasource.dart';

class TryOnHistoryRepositoryImpl implements TryOnHistoryRepository {
  TryOnHistoryRepositoryImpl(this._remote);

  final TryOnHistoryRemoteDataSource _remote;

  @override
  Stream<List<TryOnHistoryItem>> watchHistory(String uid) {
    return _remote.watchHistory(uid);
  }
}
