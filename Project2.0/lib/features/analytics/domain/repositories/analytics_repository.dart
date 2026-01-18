import '../entities/closet_analytics.dart';

abstract class AnalyticsRepository {
  Stream<ClosetAnalytics> watchClosetAnalytics(String uid);
}
