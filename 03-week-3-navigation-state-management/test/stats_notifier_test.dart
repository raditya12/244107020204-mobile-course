import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  // Setiap test memiliki container sendiri agar state tidak saling bocor.
  ProviderContainer createContainer(StatsNotifier Function() create) {
    final container = ProviderContainer(
      overrides: [statsProvider.overrideWith(create)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'loading menunggu delay 2 detik lalu menghasilkan 3 statistik',
    () async {
      // Completer menahan respons tanpa menunggu dua detik di dunia nyata.
      final gate = Completer<void>();
      Duration? requestedDelay;
      final container = createContainer(
        () => StatsNotifier(
          delay: (duration) {
            requestedDelay = duration;
            return gate.future;
          },
          randomValue: () => 0.8,
        ),
      );

      expect(
        container.read(statsProvider),
        isA<AsyncLoading<List<StatItem>>>(),
      );
      expect(requestedDelay, const Duration(seconds: 2));

      gate.complete();
      final items = await container.read(statsProvider.future);
      expect(items.map((item) => item.label), [
        'Total pengguna',
        'Pengguna aktif',
        'Transaksi hari ini',
      ]);
      expect(items.map((item) => item.value), [1200, 850, 320]);
      expect(container.read(statsProvider), isA<AsyncData<List<StatItem>>>());
    },
  );

  // Nilai batas memastikan peluang gagal memakai < 0.30, bukan <= 0.30.
  for (final value in [0.0, 0.299999, 0.30, 0.999999]) {
    test('peluang gagal sesuai batas untuk angka $value', () async {
      final container = createContainer(
        () => StatsNotifier(delay: (_) async {}, randomValue: () => value),
      );

      if (value < 0.30) {
        await expectLater(
          container.read(statsProvider.future),
          throwsA(isA<Exception>()),
        );
        expect(
          container.read(statsProvider),
          isA<AsyncError<List<StatItem>>>(),
        );
      } else {
        expect(await container.read(statsProvider.future), hasLength(3));
        expect(container.read(statsProvider).hasError, isFalse);
      }
    });
  }

  test('retry berpindah dari error ke loading lalu sukses', () async {
    var attempts = 0;
    final retryGate = Completer<void>();
    final container = createContainer(
      () => StatsNotifier(
        delay: (_) async {
          attempts++;
          if (attempts == 2) await retryGate.future;
        },
        randomValue: () => attempts == 1 ? 0.1 : 0.9,
      ),
    );

    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<Exception>()),
    );
    expect(container.read(statsProvider).hasError, isTrue);

    // Sama seperti tombol UI: invalidate membuang hasil gagal dan memuat ulang.
    container.invalidate(statsProvider);
    expect(container.read(statsProvider).isLoading, isTrue);
    retryGate.complete();
    expect(await container.read(statsProvider.future), hasLength(3));
    expect(container.read(statsProvider).hasError, isFalse);
    expect(attempts, 2);
  });
}
