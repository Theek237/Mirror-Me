import 'package:equatable/equatable.dart';

enum TryOnStatus { idle, loading, success, failure }

class TryOnState extends Equatable {
  const TryOnState({required this.status, this.result, this.message});

  factory TryOnState.initial() => const TryOnState(status: TryOnStatus.idle);

  final TryOnStatus status;
  final Map<String, dynamic>? result;
  final String? message;

  TryOnState copyWith({
    TryOnStatus? status,
    Map<String, dynamic>? result,
    String? message,
  }) {
    return TryOnState(
      status: status ?? this.status,
      result: result ?? this.result,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, result, message];
}
