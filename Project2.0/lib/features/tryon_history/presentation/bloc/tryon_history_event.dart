import 'package:equatable/equatable.dart';

abstract class TryOnHistoryEvent extends Equatable {
  const TryOnHistoryEvent();

  @override
  List<Object?> get props => [];
}

class TryOnHistoryStarted extends TryOnHistoryEvent {
  const TryOnHistoryStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}
