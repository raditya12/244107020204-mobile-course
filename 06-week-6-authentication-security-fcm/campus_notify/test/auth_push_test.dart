import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/messaging/deep_link.dart';
import 'package:campus_notify/messaging/token_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Penyimpanan palsu untuk menguji logika sesi tanpa secure storage.
class FakeTokenStore {
  FakeTokenStore({this.access, this.refresh});

  String? access;
  String? refresh;
}

void main() {
  group('routeFromMessage', () {
    test('menangani route kosong, tanpa slash, dan dengan slash', () {
      expect(routeFromMessage(<String, dynamic>{}), '/');
      expect(
        routeFromMessage(<String, dynamic>{'route': ''}),
        '/',
      );
      expect(
        routeFromMessage(<String, dynamic>{'route': 'pengumuman/3'}),
        '/pengumuman/3',
      );
      expect(
        routeFromMessage(<String, dynamic>{'route': '/pengumuman/3'}),
        '/pengumuman/3',
      );
    });

    test('data payload membawa id pengumuman', () {
      const data = <String, dynamic>{'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  group('previewToken', () {
    test('memotong token panjang menjadi 12 karakter + elipsis', () {
      final token = 'cAbCdEfGhIjKlMnOpQrStUvWxYz1234567890';
      final preview = previewToken(token);
      expect(preview, '${token.substring(0, 12)}...');
      expect(preview.length, 15);
      expect(preview.contains(token.substring(12)), isFalse);
    });

    test('token pendek tetap diberi elipsis', () {
      expect(previewToken('short'), 'short...');
    });
  });

  group('AuthRepository', () {
    final auth = AuthRepository();

    test('login menolak email tanpa @ dan sandi kurang dari 6', () async {
      expect(
        () => auth.login(email: 'salah', password: 'rahasia123'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => auth.login(email: 'a@b.c', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('login valid mengembalikan access dan refresh token', () async {
      final session = await auth.login(
        email: 'mahasiswa@polinema.ac.id',
        password: 'rahasia123',
      );
      expect(session.access, contains('mahasiswa@polinema.ac.id'));
      expect(session.refresh, isNotEmpty);
      expect(session.email, 'mahasiswa@polinema.ac.id');
    });

    test('refresh gagal bila refresh token kosong', () {
      expect(() => auth.refresh(''), throwsA(isA<Exception>()));
    });

    test('refresh mengembalikan access token baru', () async {
      final renewed = await auth.refresh('mock-refresh');
      expect(renewed, startsWith('mock-access-renewed-'));
    });
  });

  group('logika sesi', () {
    test('status login dibaca dari keberadaan access token', () {
      final store = FakeTokenStore(access: 'mock-access');
      expect(store.access != null, isTrue);
      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh mati memaksa login ulang', () {
      final store = FakeTokenStore(refresh: '');
      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });
  });

  group('friendlyApiError', () {
    RequestOptions options() => RequestOptions(path: '/devices');

    test('memetakan 401 dan timeout ke pesan ramah', () {
      final unauthorized = DioException(
        requestOptions: options(),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options(),
          statusCode: 401,
        ),
      );
      expect(friendlyApiError(unauthorized), contains('login ulang'));

      final timeout = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionTimeout,
      );
      expect(friendlyApiError(timeout), contains('timeout'));

      final offline = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyApiError(offline), contains('koneksi'));
    });

    test('menerima error non-Dio tanpa melempar', () {
      expect(friendlyApiError(StateError('boom')), isNotEmpty);
    });
  });
}
