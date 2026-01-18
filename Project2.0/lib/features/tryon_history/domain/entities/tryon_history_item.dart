import 'package:equatable/equatable.dart';

class TryOnHistoryItem extends Equatable {
  const TryOnHistoryItem({
    required this.id,
    required this.itemName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String itemName;
  final String status;
  final String createdAt;

  @override
  List<Object?> get props => [id, itemName, status, createdAt];
}
