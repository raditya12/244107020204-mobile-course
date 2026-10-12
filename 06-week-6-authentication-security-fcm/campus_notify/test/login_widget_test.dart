import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/main.dart';
import 'package:campus_notify/providers/app_providers.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Token store tanpa plugin native agar widget test berjalan di Dart VM.
class _FakeTokenStore extends TokenStore {
  @override
  Future<String?> readAccess() async => null;

  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<String?> readEmail() async => null;

  @override
  Future<void> save({
    required String access,
    required String refresh,
    String? email,
  }) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('guard route mengarahkan ke halaman login saat belum login',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(_FakeTokenStore()),
          firebaseReadyProvider.overrideWithValue(false),
        ],
        child: const CampusNotifyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
