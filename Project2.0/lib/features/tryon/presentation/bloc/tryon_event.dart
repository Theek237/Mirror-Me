import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class TryOnEvent extends Equatable {
  const TryOnEvent();

  @override
  List<Object?> get props => [];
}

class SubmitTryOnRequested extends TryOnEvent {
  const SubmitTryOnRequested({
    required this.userId,
    required this.photoBytes,
    required this.wardrobeItemId,
    required this.wardrobeItemName,
    this.wardrobeItemImageUrl,
  });

  final String userId;
  final Uint8List photoBytes;
  final String wardrobeItemId;
  final String wardrobeItemName;
  final String? wardrobeItemImageUrl;

  @override
  List<Object?> get props => [
    userId,
    photoBytes,
    wardrobeItemId,
    wardrobeItemName,
    wardrobeItemImageUrl,
  ];
}
