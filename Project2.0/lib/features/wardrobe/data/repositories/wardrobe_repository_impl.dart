import '../../domain/entities/wardrobe_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_remote_datasource.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  WardrobeRepositoryImpl(this._remote);

  final WardrobeRemoteDataSource _remote;

  @override
  Stream<List<WardrobeItem>> watchWardrobeItems(String uid) {
    return _remote.watchWardrobeItems(uid);
  }
}
