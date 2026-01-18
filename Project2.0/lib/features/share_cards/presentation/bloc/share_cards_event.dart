import 'package:equatable/equatable.dart';

abstract class ShareCardsEvent extends Equatable {
  const ShareCardsEvent();

  @override
  List<Object?> get props => [];
}

class ShareCardsStarted extends ShareCardsEvent {
  const ShareCardsStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}
