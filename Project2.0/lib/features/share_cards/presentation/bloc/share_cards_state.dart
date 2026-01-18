import 'package:equatable/equatable.dart';

import '../../domain/entities/recommendation_card.dart';

enum ShareCardsStatus { idle, loading, failure }

class ShareCardsState extends Equatable {
  const ShareCardsState({
    required this.status,
    required this.cards,
    this.message,
  });

  factory ShareCardsState.initial() {
    return const ShareCardsState(
      status: ShareCardsStatus.idle,
      cards: <RecommendationCard>[],
    );
  }

  final ShareCardsStatus status;
  final List<RecommendationCard> cards;
  final String? message;

  ShareCardsState copyWith({
    ShareCardsStatus? status,
    List<RecommendationCard>? cards,
    String? message,
  }) {
    return ShareCardsState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, cards, message];
}
