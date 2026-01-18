import '../entities/outfit_collection.dart';

abstract class CollectionsRepository {
  Stream<List<OutfitCollection>> watchCollections(String uid);
  Future<void> createCollection({required String uid, required String name});
}
