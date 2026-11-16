/// Instrumentasi hitung rebuild khusus debugging/profiling (Minggu 11).
///
/// Semua pencatatan berada di dalam [assert] sehingga build release tidak
/// membayar biaya apa pun (dieksekusi nol kali). Dipakai untuk mengukur
/// secara terukur dampak optimasi rebuild: selisih (delta) jumlah build
/// per label sebelum dan sesudah aksi UI, misalnya toggle mode offline.
abstract final class RebuildStats {
  static final Map<String, int> _counts = {};

  /// Mencatat satu kali build untuk [label] (hanya saat assert aktif).
  static void count(String label) {
    assert(() {
      _counts[label] = (_counts[label] ?? 0) + 1;
      return true;
    }());
  }

  /// Jumlah build tercatat untuk [label] sejak reset terakhir.
  static int of(String label) => _counts[label] ?? 0;

  /// Mengosongkan seluruh counter (hanya saat assert aktif).
  static void reset() {
    assert(() {
      _counts.clear();
      return true;
    }());
  }
}
