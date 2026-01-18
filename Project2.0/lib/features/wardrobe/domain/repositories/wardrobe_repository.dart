import '../entities/wardrobe_item.dart';

abstract class WardrobeRepository {
  Stream<List<WardrobeItem>> watchWardrobeItems(String uid);
}
