import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsStarted extends AnalyticsEvent {
  const AnalyticsStarted({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}
