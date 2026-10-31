import 'package:dio/dio.dart';

/// Memetakan exception mentah menjadi pesan ramah pengguna.
///
/// UI hanya menerima `String`, bukan [DioException], agar tidak ada detail
/// teknis (atau token) yang bocor ke layar/log.
String friendlyApiError(Object error) {
  if (error is! DioException) {
    return 'Terjadi kesalahan tak terduga.';
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi ke server timeout. Silakan coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    case DioExceptionType.badCertificate:
      return 'Sertifikat server tidak valid.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) return 'Sesi berakhir. Silakan login ulang.';
      if (code == 403) return 'Akses ditolak.';
      if (code != null && code >= 500) {
        return 'Server sedang bermasalah. Coba beberapa saat lagi.';
      }
      return 'Permintaan gagal (kode $code).';
    case DioExceptionType.unknown:
      return 'Gagal terhubung ke server.';
  }
}
