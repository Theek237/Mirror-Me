class ServerException implements Exception {
  final String? message;
  ServerException({this.message});

  @override
  String toString() => message ?? 'Server Exception';
}

class CacheException implements Exception {
  final String? message;
  CacheException({this.message});

  @override
  String toString() => message ?? 'Cache Exception';
}
