import 'package:equatable/equatable.dart';

abstract class StyleQuizEvent extends Equatable {
  const StyleQuizEvent();

  @override
  List<Object?> get props => [];
}

class StyleQuizStarted extends StyleQuizEvent {
  const StyleQuizStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class StyleSelected extends StyleQuizEvent {
  const StyleSelected({required this.style, required this.selected});

  final String style;
  final bool selected;

  @override
  List<Object?> get props => [style, selected];
}

class OccasionSelected extends StyleQuizEvent {
  const OccasionSelected({required this.occasion, required this.selected});

  final String occasion;
  final bool selected;

  @override
  List<Object?> get props => [occasion, selected];
}

class StyleQuizSaved extends StyleQuizEvent {
  const StyleQuizSaved({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

class StyleQuizMessageCleared extends StyleQuizEvent {
  const StyleQuizMessageCleared();
}
