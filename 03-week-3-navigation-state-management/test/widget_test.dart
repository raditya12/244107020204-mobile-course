import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/pages/stats_page.dart';
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
        child: const MaterialApp(home: StatsPage()),
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
