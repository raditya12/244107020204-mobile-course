# Hasil testing — 11 Oktober 2026

## Pemeriksaan kode dan build

```text
flutter analyze
No issues found!

flutter test
All tests passed! (13 tests)

flutter build web
Built build\web

flutter build apk --debug
Built build\app\outputs\flutter-apk\app-debug.apk
```

Build Android memerlukan dua perbaikan konfigurasi (desugaring dan
`kotlin.incremental=false`). Setelah perbaikan, APK debug berhasil dibangun.

## Cakupan test otomatis (13 test)

- `test/auth_push_test.dart`
  - `routeFromMessage`: route kosong, tanpa slash, dengan slash, dan payload
    yang membawa `id`.
  - `previewToken`: pemotongan 12 karakter + elipsis dan token pendek.
  - `AuthRepository`: login tidak valid (tanpa `@`, sandi < 6), login valid,
    refresh gagal saat token kosong, refresh menghasilkan access baru.
  - Logika sesi: status login dari access token, refresh mati memaksa login.
  - `friendlyApiError`: pemetaan 401, timeout, offline, dan error non-Dio.
- `test/login_widget_test.dart`
  - Guard route: belum login otomatis diarahkan ke halaman `/login`.

## Pengujian aplikasi web (Playwright)

Perintah: `py tool/capture_screenshots.py` setelah `build/web` dilayani pada
`http://127.0.0.1:8766`.

```json
{
  "result": "PASS",
  "screenshots": 4,
  "observations": [
    "guard route: belum login -> /login",
    "login mock -> home, token disimpan di secure storage",
    "token ditampilkan terpotong (12 karakter)",
    "deep link /pengumuman/3 membuka halaman tujuan",
    "rute detail bertahan setelah reload"
  ],
  "page_errors": []
}
```

| File | Hasil yang terlihat |
|---|---|
| `01-halaman-login.png` | Halaman login tampil; guard mengarahkan ke `/login` saat belum ada token |
| `02-home-sesi-dan-token.png` | Sesi aktif, access token terpotong (`mock-access-...`), status topik, tombol debug |
| `03-halaman-pengumuman-deep-link.png` | Deep link `/pengumuman/3` membuka detail "Jadwal kuliah berubah" |
| `04-pengumuman-setelah-reload.png` | Rute detail bertahan setelah reload langsung |

## Matriks pengujian tiga app state (FCM)

Uji ini memerlukan project Firebase + perangkat fisik. Isi tabel berikut saat
project Firebase tersedia. Payload uji:

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": { "title": "Jadwal kuliah berubah", "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00" },
    "data": { "route": "/pengumuman/3", "id": "3" }
  }
}
```

| State | Yang diharapkan | Cara uji | Status |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari console/backend | Belum diuji di perangkat |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik banner | Belum diuji di perangkat |
| Terminated | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik banner | Belum diuji di perangkat |

Bagian yang **sudah** dibuktikan tanpa Firebase:

- Parsing `data.route` menjadi rute GoRouter (unit test).
- Deep link `/pengumuman/:id` membuka halaman tujuan (web).
- Guard route dan penyimpanan token (web + widget test).

## Lifecycle token

- `getToken()` + `onTokenRefresh` sudah terhubung ke `POST /devices` lewat
  `DeviceRepository.registerDevice()`. Karena backend contoh belum aktif,
  kegagalan jaringan disimpan lokal agar token tetap terlihat di halaman Debug.
- Langganan topik `pengumuman-kampus` tersedia lewat tombol Subscribe/Unsubscribe.
- Bukti `onTokenRefresh` memperbarui token backend (hapus data/reinstall) perlu
  dijalankan pada perangkat dengan project Firebase.

## Mengulang pengujian web

```bash
flutter build web --no-tree-shake-icons
py -m http.server 8766 --bind 127.0.0.1 --directory build/web
```

Di terminal lain pada folder project yang sama:

```bash
py -m pip install playwright
py -m playwright install chromium
py tool/capture_screenshots.py
```

Script memakai context browser baru, bukan profil pribadi. Screenshot ditulis
ulang dengan hasil sesi terbaru.
