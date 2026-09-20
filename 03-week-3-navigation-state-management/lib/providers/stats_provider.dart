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
