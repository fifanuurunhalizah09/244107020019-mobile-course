import 'package:dio/dio.dart';

String friendlyError(Object e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi terlalu lama';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet';
      case DioExceptionType.badResponse:
        return 'HTTP ${e.response?.statusCode}';
      default:
        return 'Terjadi kesalahan';
    }
  }
  return e.toString();
}