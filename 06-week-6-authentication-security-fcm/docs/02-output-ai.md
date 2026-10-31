# Output awal AI

Ringkasan draf awal yang dihasilkan AI sebelum diverifikasi manual. Draf ini
dipakai sebagai titik awal, lalu diperbaiki pada [`03-verifikasi-fcm.md`](03-verifikasi-fcm.md).

## Struktur yang diusulkan AI

```text
lib/
├── main.dart
├── routes.dart
├── router.dart
├── data/
│   ├── token_store.dart
│   ├── auth_repository.dart
│   ├── api_client.dart
│   ├── api_errors.dart
│   └── device_repository.dart
├── providers/
│   ├── auth_provider.dart
│   └── app_providers.dart
├── messaging/
│   ├── push_service.dart
│   ├── deep_link.dart
│   └── token_preview.dart
└── pages/
    ├── login_page.dart
    ├── home_page.dart
    └── announcement_page.dart
```

## Draf `PushService` (bagian inti)

AI mengusulkan kelas `PushService` dengan method berikut:

- `requestNotificationPermission()` memakai
  `FirebaseMessaging.instance.requestPermission(alert, badge, sound)`.
- `initFcmToken()` memanggil `getToken()` lalu mendengarkan `onTokenRefresh`.
- `onMessage` menampilkan local notification manual via
  `flutter_local_notifications`.
- `onMessageOpenedApp` dan `getInitialMessage` memanggil navigasi ke
  `message.data['route']`.
- `subscribeToTopic`/`unsubscribeFromTopic` untuk topik `pengumuman-kampus`.
- Background handler top-level dengan `@pragma('vm:entry-point')`.

## Perbedaan Android 13+ vs iOS menurut AI

| Aspek | Android 13+ | iOS |
|---|---|---|
| Izin notifikasi | Runtime `POST_NOTIFICATIONS`; perlu manifest + request izin | `requestPermission` (alert/badge/sound); perlu APNs key & capability Push |
| Channel | Wajib `AndroidNotificationDetails` dengan `channelId`/`importance` | Tidak ada konsep channel; pakai `DarwinNotificationDetails` |
| Banner foreground | Sistem tidak menampilkan otomatis, harus local notification | Sama, foreground tidak menampilkan otomatis |
| Header tampilan | Perlu `AndroidInitializationSettings('@mipmap/ic_launcher')` | Perlu `DarwinInitializationSettings` |

## Bagian yang tidak boleh mengakses `BuildContext`

AI menandai bahwa background handler
(`firebaseMessagingBackgroundHandler`) berjalan di isolate terpisah sehingga
**tidak boleh** mengakses `BuildContext`, Riverpod, atau navigasi. Tugasnya hanya
mencatat/menyimpan data ringan; navigasi dilakukan saat notifikasi diklik.

## Catatan versi paket

Draf awal memakai API `flutter_local_notifications` versi lama
(`initialize(settings, onDidReceive...)` dan `show(id, title, body, details)`).
Pada paket versi 22.3.1 yang terpasang, seluruh parameter bernama (`named
parameters`) berubah. Perbaikan ini dicatat pada dokumen verifikasi.
