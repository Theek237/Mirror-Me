import '../../domain/entities/closet_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteDataSource _remote;

  @override
  Stream<ClosetAnalytics> watchClosetAnalytics(String uid) {
    return _remote.watchClosetAnalytics(uid);
  }
}
