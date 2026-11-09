# Hasil Testing — Jobsheet 10

**Tanggal:** 9 November 2026
**Project:** `10-week-10-ai-feature-integration`
**Fokus:** chat asisten AI + fallback offline/error

## Ringkasan

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `dart format --set-exit-if-changed` | exit 0 |
| `flutter test` | 42 test, semua hijau (stabil 3x beruntun) |
| Test baru | 11 (4 parsing + 3 use case + 4 widget) |
| Uji manual | 4 skenario, screenshot tersedia |

## Test baru

### `test/gemini_parse_test.dart`

Menguji parsing respons Gemini secara murni (tanpa jaringan):

| Test | Input | Harapan |
|---|---|---|
| Respons normal | `candidates[0].content.parts[].text` | Teks ter-trim, tanpa failure |
| Candidates kosong | `{'candidates': []}` | `NetworkFailure`, reply kosong |
| Jawaban diblokir | `finishReason: SAFETY` tanpa content | `NetworkFailure` |
| Parts tanpa teks | `inlineData` saja | `NetworkFailure` |

Tiga test pertama-lah yang sempat merah pada draft AI (bukti di
[`ai-log.md`](ai-log.md#4-bukti-bughalusinasi)).

### `test/ask_assistant_test.dart`

| Test | Input | Harapan |
|---|---|---|
| Trim | `'  Jadwal hari ini?  '` | Repository menerima versi trim |
| Kosong | `'   '` | `ValidationFailure`, repository tidak dipanggil |
| Gagal | failure dari repository | Diteruskan tanpa exception |

### `test/chat_widget_test.dart`

Widget test dengan `FakeAssistantRepository` (tanpa jaringan):

1. Kirim pertanyaan → bubble user + balasan asisten tampil.
2. Kirim kosong → repository tidak dipanggil, tanpa kartu error.
3. AI gagal → kartu error ramah; "Coba lagi" dengan repo yang kini sukses menghapus error dan menampilkan balasan.
4. Mode offline → repository tidak dipanggil, kartu error tampil.

## Uji manual

Build web dijalankan lokal, lalu diuji lewat browser.

| Skenario | Aksi | Hasil | Screenshot |
|---|---|---|---|
| Halaman chat kosong | Buka `/chat` | Empty state + peringatan privasi | [`00-chat-kosong.png`](../screenshots/00-chat-kosong.png) |
| Tanpa API key | Kirim pertanyaan | Pesan "API key belum diatur..." | [`01-chat-tanpa-api-key.png`](../screenshots/01-chat-tanpa-api-key.png) |
| Blokir offline | Aktifkan mode offline, kirim pertanyaan | Banner oranye + kartu error, tidak ada request | [`02-chat-offline.png`](../screenshots/02-chat-offline.png) |
| Pengaturan API key | Buka Pengaturan | Kolom key tersimpan lokal (obscured) | [`03-pengaturan-api-key.png`](../screenshots/03-pengaturan-api-key.png) |

## Perintah dan output

```text
flutter analyze
No issues found! (ran in 3.7s)

dart format --output=none --set-exit-if-changed lib test
Formatted 56 files (0 changed) in 0.15 seconds.
format_exit=0

flutter test
00:11 +42: All tests passed!
00:08 +42: All tests passed!
00:17 +42: All tests passed!
```

## Catatan teknis

- Semua test AI memakai fake repository; tidak ada panggilan jaringan nyata
  di `flutter test`, sehingga CI tidak butuh API key.
- API key nyata hanya dibutuhkan saat demo manual; key tidak pernah masuk
  kode sumber maupun repository.
- Test lama `markSynced tidak membersihkan versi yang lebih baru` diberi jeda
  5 ms antara add dan update karena `DateTime.now()` bisa jatuh di milidetik
  sama dan membuat guard "versi lebih baru" tidak terpicu (flaky).
- Screenshot diambil dari build web nyata, bukan mockup.