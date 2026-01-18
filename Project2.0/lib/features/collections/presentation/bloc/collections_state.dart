import 'package:equatable/equatable.dart';

import '../../domain/entities/outfit_collection.dart';

enum CollectionsStatus { idle, loading, saving, failure }

class CollectionsState extends Equatable {
  const CollectionsState({
    required this.status,
    required this.collections,
    this.message,
  });

  factory CollectionsState.initial() {
    return const CollectionsState(
      status: CollectionsStatus.idle,
      collections: <OutfitCollection>[],
    );
  }

  final CollectionsStatus status;
  final List<OutfitCollection> collections;
  final String? message;

  CollectionsState copyWith({
    CollectionsStatus? status,
    List<OutfitCollection>? collections,
    String? message,
  }) {
    return CollectionsState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, collections, message];
}
