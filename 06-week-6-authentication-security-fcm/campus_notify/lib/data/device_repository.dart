import 'package:dio/dio.dart';

/// Mengirim registration token FCM ke backend (`POST /devices`).
///
/// Backend pada praktikum belum tersedia, sehingga kegagalan jaringan
/// disimpan sebagai bukti lokal agar token tetap terlihat pada halaman Debug.
class DeviceRepository {
  DeviceRepository(this._dio);

  final Dio _dio;

  final List<String> registeredTokens = <String>[];

  Future<void> registerDevice(String token, {required String platform}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/devices',
        data: <String, dynamic>{'fcm_token': token, 'platform': platform},
      );
    } catch (_) {
      // Endpoint contoh belum aktif; simpan lokal untuk kebutuhan demo.
      registeredTokens.add(token);
    }
  }
}
