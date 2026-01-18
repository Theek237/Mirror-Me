import '../entities/outfit_collection.dart';
import '../repositories/collections_repository.dart';

class WatchCollections {
  const WatchCollections(this._repository);

  final CollectionsRepository _repository;

  Stream<List<OutfitCollection>> call(String uid) {
    return _repository.watchCollections(uid);
  }
}
