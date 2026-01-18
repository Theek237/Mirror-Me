import 'package:equatable/equatable.dart';

enum StyleQuizStatus { idle, loading, saving, success, failure }

class StyleQuizState extends Equatable {
  const StyleQuizState({
    required this.status,
    required this.styles,
    required this.occasions,
    this.message,
  });

  factory StyleQuizState.initial() {
    return const StyleQuizState(
      status: StyleQuizStatus.idle,
      styles: <String>{},
      occasions: <String>{},
    );
  }

  final StyleQuizStatus status;
  final Set<String> styles;
  final Set<String> occasions;
  final String? message;

  StyleQuizState copyWith({
    StyleQuizStatus? status,
    Set<String>? styles,
    Set<String>? occasions,
    String? message,
  }) {
    return StyleQuizState(
      status: status ?? this.status,
      styles: styles ?? this.styles,
      occasions: occasions ?? this.occasions,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, styles, occasions, message];
}
