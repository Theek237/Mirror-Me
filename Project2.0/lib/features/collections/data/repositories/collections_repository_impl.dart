import '../../domain/entities/outfit_collection.dart';
import '../../domain/repositories/collections_repository.dart';
import '../datasources/collections_remote_datasource.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  CollectionsRepositoryImpl(this._remote);

  final CollectionsRemoteDataSource _remote;

  @override
  Stream<List<OutfitCollection>> watchCollections(String uid) =>
      _remote.watchCollections(uid);

  @override
  Future<void> createCollection({required String uid, required String name}) {
    return _remote.createCollection(uid: uid, name: name);
  }
}
