import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  const ServerException({
    required this.message,
    required this.statusCode,
  });
  final String message;
  final String statusCode;
  @override
  List<dynamic> get props => [message, statusCode];
}

class CacheExceptions extends Equatable implements Exception {
  const CacheExceptions({
    required this.message,
    this.statusCode = 500,
  });

  final String message;
  final int statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}
