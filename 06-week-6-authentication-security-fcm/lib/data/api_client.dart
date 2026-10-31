import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

/// Membuat Dio dengan interceptor yang:
/// 1. menyisipkan `Authorization: Bearer <access>` pada setiap request;
/// 2. saat menerima 401, mencoba refresh **satu kali** lalu mengulang request;
/// 3. bila refresh ikut gagal, membersihkan sesi (memaksa login ulang).
Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null) return handler.next(error);
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
            final retry = await dio.fetch(
              error.requestOptions
                ..headers['Authorization'] = 'Bearer $renewed',
            );
            return handler.resolve(retry);
          } catch (_) {
            await store.clear(); // refresh ikut mati -> paksa login ulang
          }
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}
