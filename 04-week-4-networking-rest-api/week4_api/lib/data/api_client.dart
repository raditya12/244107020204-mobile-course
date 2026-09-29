import 'package:dio/dio.dart';

// Seluruh repository memakai URL dan batas waktu per fase yang sama.
// Ini timeout koneksi/kirim/terima, bukan batas total durasi request.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));
  return dio;
}
