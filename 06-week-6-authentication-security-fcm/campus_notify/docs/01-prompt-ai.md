# Prompt AI Challenge

Tanggal penyusunan: 11 Oktober 2026. Asisten: OpenCode.

Prompt yang dipakai diambil langsung dari jobsheet minggu 6:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

Jawaban awal AI disimpan di [`02-output-ai.md`](02-output-ai.md). Hasil pemeriksaan,
perbaikan manual, dan keputusan teknis disimpan di
[`03-verifikasi-fcm.md`](03-verifikasi-fcm.md). Hasil perintah dan pengujian
disimpan di [`04-hasil-testing.md`](04-hasil-testing.md).

Dokumen ini disusun pada sesi pengerjaan jobsheet, bukan rekaman percakapan lama.
