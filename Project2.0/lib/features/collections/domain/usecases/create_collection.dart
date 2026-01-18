import '../repositories/collections_repository.dart';

class CreateCollection {
  const CreateCollection(this._repository);

  final CollectionsRepository _repository;

  Future<void> call({required String uid, required String name}) {
    return _repository.createCollection(uid: uid, name: name);
  }
}
