import '../entities/wardrobe_item.dart';
import '../repositories/wardrobe_repository.dart';

class WatchWardrobeItems {
  WatchWardrobeItems(this._repository);

  final WardrobeRepository _repository;

  Stream<List<WardrobeItem>> call(String uid) {
    return _repository.watchWardrobeItems(uid);
  }
}
