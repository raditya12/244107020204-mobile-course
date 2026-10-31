import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/device_repository.dart';
import '../messaging/push_service.dart';
import 'auth_provider.dart';

/// Di-override di `main()` sesuai hasil `Firebase.initializeApp()`.
final firebaseReadyProvider = Provider<bool>((ref) => false);

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(ref.watch(apiClientProvider)),
);

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(firebaseReady: ref.watch(firebaseReadyProvider));
  ref.onDispose(service.dispose);
  return service;
});
