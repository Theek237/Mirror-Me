import 'package:equatable/equatable.dart';

import '../../domain/entities/closet_analytics.dart';

enum AnalyticsStatus { idle, loading, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({required this.status, this.analytics, this.message});

  factory AnalyticsState.initial() {
    return const AnalyticsState(status: AnalyticsStatus.idle);
  }

  final AnalyticsStatus status;
  final ClosetAnalytics? analytics;
  final String? message;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    ClosetAnalytics? analytics,
    String? message,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, analytics, message];
}
