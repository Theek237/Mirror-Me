import '../entities/closet_analytics.dart';
import '../repositories/analytics_repository.dart';

class WatchClosetAnalytics {
  const WatchClosetAnalytics(this._repository);

  final AnalyticsRepository _repository;

  Stream<ClosetAnalytics> call(String uid) {
    return _repository.watchClosetAnalytics(uid);
  }
}
