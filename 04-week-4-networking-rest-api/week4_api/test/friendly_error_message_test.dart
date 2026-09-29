import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/network_errors.dart';

void main() {
  // Seluruh enum tercakup, termasuk sertifikat, pembatalan, dan unknown.
  final messages = {
    DioExceptionType.transformTimeout:
        'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.',
    DioExceptionType.connectionTimeout:
        'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.',
    DioExceptionType.sendTimeout:
        'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.',
    DioExceptionType.receiveTimeout:
        'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.',
    DioExceptionType.connectionError:
        'Tidak dapat terhubung ke server. Periksa internet Anda.',
    DioExceptionType.badResponse: 'Permintaan gagal. Coba lagi nanti.',
    DioExceptionType.badCertificate:
        'Koneksi aman ke server tidak dapat diverifikasi.',
    DioExceptionType.cancel: 'Permintaan dibatalkan. Silakan coba lagi.',
    DioExceptionType.unknown: 'Terjadi kesalahan jaringan. Coba lagi.',
  };
  for (final type in DioExceptionType.values) {
    test('pesan ramah pengguna untuk $type', () {
      expect(
        friendlyErrorMessage(
          DioException(requestOptions: RequestOptions(), type: type),
        ),
        messages[type],
      );
    });
  }
  test('error parsing dan error tak terduga tidak membocorkan detail', () {
    expect(
      friendlyErrorMessage(const FormatException('internal')),
      'Format data server tidak valid.',
    );
    expect(
      friendlyErrorMessage(StateError('internal')),
      'Terjadi kesalahan tak terduga. Silakan coba lagi.',
    );
  });
}
