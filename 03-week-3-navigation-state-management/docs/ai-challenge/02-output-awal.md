# 02 — Output awal AI

Arsip ini menyimpan kode hasil implementasi awal setelah formatter, sebelum permintaan audit checklist. Pada audit lanjutan tidak ada perubahan kode Dart. Snapshot kode aplikasi di bawah disertai arsip test; format pembungkusan baris test disederhanakan untuk dokumentasi, tanpa mengubah logikanya.

## Ringkasan respons awal AI

AI melaporkan implementasi selesai di `week3_todo`, dengan komentar berbahasa Indonesia, satu provider statistik, delay dua detik dan peluang gagal 30%, tiga keadaan UI, StatsPage sebagai halaman awal, enam unit test dan satu widget test. Verifikasi saat itu: tujuh test lulus dan analyzer melaporkan `No issues found!`.

## `lib/providers/stats_provider.dart`

```dart
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model immutable untuk satu baris statistik: nama metrik dan nilainya.
class StatItem {
  const StatItem(this.label, this.value);

  final String label;
  final int value;
}

// Satu provider menyimpan AsyncValue<List<StatItem>> untuk seluruh StatsPage.
// Retry otomatis Riverpod 3 dinonaktifkan agar error tetap terlihat sampai
// pengguna menekan tombol retry.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
  retry: (retryCount, error) => null,
);

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  // Dependency injection memungkinkan unit test mengontrol waktu dan peluang
  // gagal, sementara aplikasi menggunakan delay dan angka acak sungguhan.
  StatsNotifier({
    Future<void> Function(Duration)? delay,
    double Function()? randomValue,
  }) : _delay = delay ?? _wait,
       _randomValue = randomValue ?? Random().nextDouble;

  final Future<void> Function(Duration) _delay;
  final double Function() _randomValue;

  static Future<void> _wait(Duration duration) =>
      Future<void>.delayed(duration);

  // Riverpod mengubah Future ini menjadi loading, data, atau error secara
  // otomatis. Invalidate dari tombol retry akan menjalankan build kembali.
  @override
  Future<List<StatItem>> build() async {
    await _delay(const Duration(seconds: 2));

    // nextDouble menghasilkan [0, 1); nilai di bawah 0.30 berarti peluang 30%.
    if (_randomValue() < 0.30) {
      throw Exception('Gagal mengambil statistik. Silakan coba lagi.');
    }

    // Respons simulasi selalu berisi tepat tiga item statistik.
    return const [
      StatItem('Total pengguna', 1200),
      StatItem('Pengguna aktif', 850),
      StatItem('Transaksi hari ini', 320),
    ];
  }
}
```

## `lib/pages/stats_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget menyediakan WidgetRef tanpa perlu state lokal halaman.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch membangun ulang UI setiap kali status pengambilan data berubah.
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: stats.when(
        // Tampilkan spinner juga ketika provider sedang dimuat ulang.
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        // Error ditampilkan bersama aksi untuk memulai permintaan baru.
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(statsProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        // Data sukses dirender sebagai ListView dengan tiga baris statistik.
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.label),
              trailing: Text('${item.value}'),
            );
          },
        ),
      ),
    );
  }
}
```

## `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/stats_page.dart';

void main() {
  // ProviderScope menyediakan penyimpanan state Riverpod untuk aplikasi.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stats App',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      // Halaman statistik menjadi halaman awal agar langsung dapat dicoba.
      home: const StatsPage(),
    );
  }
}
```

## `test/stats_notifier_test.dart`

```dart
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

  test('loading menunggu delay 2 detik lalu menghasilkan 3 statistik', () async {
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

    expect(container.read(statsProvider), isA<AsyncLoading<List<StatItem>>>());
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
  });

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
        expect(container.read(statsProvider), isA<AsyncError<List<StatItem>>>());
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
```

## `test/widget_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  testWidgets('StatsPage menampilkan loading, error, retry, dan tiga item', (
    tester,
  ) async {
    var attempts = 0;
    // Gunakan notifier asli dengan angka terkontrol: pertama gagal, lalu sukses.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(randomValue: () => attempts++ == 0 ? 0.1 : 0.9),
          ),
        ],
        child: const MyApp(),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Waktu virtual widget test memajukan delay tanpa menunggu waktu nyata.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.textContaining('Gagal mengambil statistik'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('Total pengguna'), findsOneWidget);
  });
}
```
