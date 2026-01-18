import 'package:equatable/equatable.dart';

import '../../domain/entities/tryon_history_item.dart';

enum TryOnHistoryStatus { idle, loading, failure }

class TryOnHistoryState extends Equatable {
  const TryOnHistoryState({
    required this.status,
    required this.items,
    this.message,
  });

  factory TryOnHistoryState.initial() {
    return const TryOnHistoryState(
      status: TryOnHistoryStatus.idle,
      items: <TryOnHistoryItem>[],
    );
  }

  final TryOnHistoryStatus status;
  final List<TryOnHistoryItem> items;
  final String? message;

  TryOnHistoryState copyWith({
    TryOnHistoryStatus? status,
    List<TryOnHistoryItem>? items,
    String? message,
  }) {
    return TryOnHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
