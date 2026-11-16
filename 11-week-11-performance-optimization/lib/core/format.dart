// Fungsi murni untuk formatting dan parsing, sehingga dapat diuji tanpa
// widget. Tidak mengimpor Flutter, Dio, maupun SQLite.

/// Format timestamp lokal tanpa komponen mikrodetik.
String formatTimestamp(DateTime value) =>
    value.toLocal().toString().split('.').first;

/// Parse parameter rute `id` menjadi integer. Mengembalikan `null` bila tidak
/// valid, sehingga pemanggil dapat memutuskan perilaku berikutnya.
int? parseNoteId(String? raw) => int.tryParse(raw ?? '');
