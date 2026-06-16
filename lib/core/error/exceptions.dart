class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server Error'});

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {}
