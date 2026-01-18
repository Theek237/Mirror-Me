import 'dart:typed_data';

abstract class TryOnRepository {
  Future<Map<String, dynamic>> submitTryOn({
    required String userId,
    required Uint8List photoBytes,
    required String wardrobeItemId,
    required String wardrobeItemName,
    String? wardrobeItemImageUrl,
  });
}
