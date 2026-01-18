import 'dart:typed_data';

import '../repositories/tryon_repository.dart';

class SubmitTryOn {
  const SubmitTryOn(this._repository);

  final TryOnRepository _repository;

  Future<Map<String, dynamic>> call({
    required String userId,
    required Uint8List photoBytes,
    required String wardrobeItemId,
    required String wardrobeItemName,
    String? wardrobeItemImageUrl,
  }) {
    return _repository.submitTryOn(
      userId: userId,
      photoBytes: photoBytes,
      wardrobeItemId: wardrobeItemId,
      wardrobeItemName: wardrobeItemName,
      wardrobeItemImageUrl: wardrobeItemImageUrl,
    );
  }
}
