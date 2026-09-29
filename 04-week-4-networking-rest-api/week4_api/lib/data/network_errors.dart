import 'package:dio/dio.dart';

/// Satu pemetaan error untuk halaman list, pagination, detail, dan komentar.
String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data tidak ditemukan (404).';
        if (code == 500) return 'Server bermasalah (500). Coba lagi nanti.';
        if (code == 401 || code == 403) {
          return 'Akses ditolak ($code). Periksa kredensial Anda.';
        }
        return 'Permintaan gagal${code == null ? '' : ' ($code)'}. Coba lagi nanti.';
      case DioExceptionType.badCertificate:
        return 'Koneksi aman ke server tidak dapat diverifikasi.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan. Silakan coba lagi.';
      case DioExceptionType.unknown:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  if (error is FormatException) return 'Format data server tidak valid.';
  return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
}
