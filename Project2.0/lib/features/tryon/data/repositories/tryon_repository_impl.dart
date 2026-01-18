import 'dart:typed_data';

import '../../domain/repositories/tryon_repository.dart';
import '../datasources/tryon_remote_datasource.dart';

class TryOnRepositoryImpl implements TryOnRepository {
  TryOnRepositoryImpl(this._remote);

  final TryOnRemoteDataSource _remote;

  @override
  Future<Map<String, dynamic>> submitTryOn({
    required String userId,
    required Uint8List photoBytes,
    required String wardrobeItemId,
    required String wardrobeItemName,
    String? wardrobeItemImageUrl,
  }) {
    return _remote.submitTryOn(
      userId: userId,
      photoBytes: photoBytes,
      wardrobeItemId: wardrobeItemId,
      wardrobeItemName: wardrobeItemName,
      wardrobeItemImageUrl: wardrobeItemImageUrl,
    );
  }
}
