# Verifikasi AI dan keputusan teknis

## Checklist verifikasi dari jobsheet

| Pertanyaan jobsheet | Temuan pada kode |
|---|---|
| Apakah background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`? | Ya. `firebaseMessagingBackgroundHandler` di `lib/messaging/push_service.dart` adalah fungsi top-level, bukan method kelas, dan diberi `@pragma('vm:entry-point')`. |
| Apakah `onTokenRefresh` benar-benar mengirim token baru ke backend, bukan hanya dicetak? | Ya. Listener memanggil `onToken(...)`, dan di `main.dart` callback tersebut memanggil `DeviceRepository.registerDevice()` yang mengirim `POST /devices`. Token tidak dicetak ke log. |
| Apakah foreground memakai local notification manual? | Ya. `onMessage` memanggil `showLocalNotification()` via `flutter_local_notifications`. |
| Apakah klik dari ketiga state masuk ke rute yang benar? | Logika route diuji unit test (`routeFromMessage`) dan deep link `/pengumuman/3` diuji pada web. Bukti tiga state pada perangkat nyata perlu Firebase + HP (lihat catatan di bawah). |
| Apakah token/secret tidak di-hardcode dan tidak di-log penuh? | Ya. Tidak ada token/secret di kode. Token hanya lewat `flutter_secure_storage`. Token FCM ditampilkan terpotong lewat `previewToken()` (12 karakter pertama). |
| Keputusan final | Draf AI diterima dengan beberapa perbaikan manual (lihat bawah). |

## Perbaikan manual terhadap draf AI

1. **API `flutter_local_notifications` 22.3.1.** Draf memakai parameter
   posisional. Diubah ke parameter bernama:
   - `initialize(settings: ..., onDidReceiveNotificationResponse: ...)`
   - `show(id: ..., title: ..., body: ..., notificationDetails: ..., payload: ...)`
2. **`DioExceptionType.transformTimeout`.** `switch` pada `api_errors.dart`
   harus menangani case baru ini agar exhaustive.
3. **Firebase opsional.** Draf memanggil `Firebase.initializeApp()` langsung dan
   akan crash bila `google-services.json` belum ada. Diubah: inisialisasi dibungkus
   `try/catch`, hasilnya disimpan pada `firebaseReadyProvider`. Bila false,
   `PushService` berjalan dalam mode demo tanpa memanggil API native.
4. **Core library desugaring.** `flutter_local_notifications` memerlukan
   desugaring; ditambahkan `isCoreLibraryDesugaringEnabled = true` dan dependensi
   `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")`.
5. **Incremental Kotlin cache.** Build `firebase_core` gagal menutup cache
   inkremental; ditambahkan `kotlin.incremental=false` pada `gradle.properties`.
6. **Refactoring jobsheet.** Rute dipindah ke `lib/routes.dart`, parsing
   `RemoteMessage -> route` diekstrak ke fungsi murni `routeFromMessage()`, dan
   pemetaan `DioException -> pesan` ke `lib/data/api_errors.dart`.

## Keputusan teknis

- **Notifikasi gabungan `notification + data`.** `notification` untuk teks yang
  dibaca manusia, `data.route` untuk deep link. Ini sebabnya klik dapat membuka
  `/pengumuman/:id` di semua state.
- **Token vs topik.** Topik `pengumuman-kampus` untuk broadcast (semua mahasiswa).
  Untuk pesan personal (nilai, tagihan) harus memakai token perangkat, bukan topik.
- **Penyimpanan token.** Hanya `flutter_secure_storage`. SharedPreferences ditolak
  karena tidak terenkripsi.

## Batasan yang jujur

Pengujian tiga app state (foreground/background/terminated) dan lifecycle token
yang sesungguhnya **memerlukan project Firebase + perangkat Android/iOS**, karena
FCM hanya mengirim ke aplikasi yang terdaftar di Firebase. Pada lingkungan
pengerjaan ini `google-services.json` tidak tersedia, sehingga yang dibuktikan
secara nyata adalah: alur auth, penyimpanan token, guard route, dan deep link
`/pengumuman/:id`. Prosedur pengujian FCM pada perangkat dicatat di
[`04-hasil-testing.md`](04-hasil-testing.md) agar dapat dijalankan saat project
Firebase tersedia.
