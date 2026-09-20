# 03 — Riwayat perubahan dan hasil audit

## A. Perubahan yang dilakukan pada implementasi awal

1. Menambahkan `lib/providers/stats_provider.dart`: model immutable, satu AsyncNotifierProvider, delay dua detik, dan peluang gagal 30%.
2. Menambahkan `lib/pages/stats_page.dart`: ConsumerWidget dengan loading, error, tombol retry, dan ListView tiga item.
3. Mengubah `lib/main.dart`: import StatsPage, judul Stats App, halaman awal StatsPage, serta komentar ProviderScope.
4. Menambahkan enam unit test pada `test/stats_notifier_test.dart` dengan delay/random terkontrol.
5. Mengganti test counter template pada `test/widget_test.dart` dengan pengujian UI statistik. Test template sebelumnya masih mengharapkan angka counter dan tombol tambah yang tidak sesuai aplikasi.
6. Menjalankan formatter untuk lima file tersebut, lalu `flutter test` dan `flutter analyze`; tujuh test lulus dan analyzer tanpa masalah.

Dependency injection, `const` list, `skipLoadingOnRefresh: false`, dan penonaktifan retry otomatis sudah merupakan bagian output awal. Tidak ada bukti kegagalan test implementasi awal yang kemudian diperbaiki; dokumentasi ini tidak mengarang siklus error/fix.

## B. Pemeriksaan lanjutan sesuai checklist

1. Memeriksa lima file hasil AI serta provider/halaman lain untuk membandingkan pola state dan nama provider.
2. Memastikan `StatItem` dan list statistik immutable.
3. Memastikan `watch` berada di build UI dan retry memakai invalidate pada callback.
4. Memastikan `when` mencakup loading, error, dan data.
5. Memastikan generic provider eksplisit dan tidak ada deklarasi statsProvider kedua.
6. Memastikan kode tidak menggunakan StateProvider/StateNotifierProvider atau Consumer bertingkat.
7. Menjalankan ulang analyzer dan seluruh test di `week3_todo`; hasil lulus.

**Perbaikan Dart setelah audit: tidak diperlukan.** Tipe generic sudah eksplisit meskipun tipe variabel final diinferensikan. `ref.invalidate` tidak perlu diganti dengan `ref.read`, karena aksi retry tidak membaca nilai provider.

## C. Perubahan dokumentasi pada tahap audit

- Menambahkan bagian **5. AI challange** pada README utama tugas minggu ini.
- Memperbaiki judul Week 2 menjadi Week 3 sesuai direktori tugas.
- Mengarsipkan prompt, output awal, riwayat perubahan, hasil test, dan panduan penjelasan kode di `docs/ai-challenge/`.

Perubahan di atas dikerjakan melalui bantuan AI. Mahasiswa tetap perlu mempelajari dan menjelaskan kode sendiri. Demo belum dijalankan atau dinilai dalam sesi audit ini.
