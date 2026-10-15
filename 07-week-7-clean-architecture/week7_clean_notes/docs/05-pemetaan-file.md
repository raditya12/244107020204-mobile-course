# Pemetaan file ke layer dan tujuan refactor

## Step 1 — Kondisi awal (project Minggu 5)

| File lama | Layer saat ini | Masalah |
|---|---|---|
| `lib/pages/notes_page.dart` | presentation | Mengakses repository langsung untuk delete; mengatur invalidasi provider; memuat widget bacaan di dalam file. |
| `lib/pages/note_detail_page.dart` | presentation | Memformat tanggal mentah (`toLocal().toString().split('.')`). |
| `lib/pages/settings_page.dart` | presentation | Mendefinisikan provider DI (`prefsRepositoryProvider`, `darkModeProvider`) di dalam file halaman. |
| `lib/widgets/note_tile.dart` | presentation | Memformat tanggal mentah di widget. |
| `lib/local/note.dart` | data (tercampur) | Entity + mapping `toMap/fromMap` jadi satu. |
| `lib/local/db.dart` | data | Opener database + factory platform di satu folder `local`. |
| `lib/data/repositories/note_repository.dart` | data (+kontrak tercampur) | Interface dan implementasi masih satu kelas; tidak ada abstraksi. |
| `lib/data/repositories/post_repository.dart` | data (+kontrak tercampur) | Model `Post` bercampur dengan implementasi repository. |
| `lib/data/sync.dart` | data | Logika bisnis sinkronisasi ada di layer data. |
| `lib/data/prefs.dart` | data | Implementasi SharedPreferences tanpa kontrak domain. |
| `lib/data/providers.dart` | data (DI) | Wiring DI ditempatkan di layer data, bukan presentation. |
| `lib/router.dart` | app | Rute tanpa konstanta terpusat. |

## Step 2 — Tiga pelanggaran klasik yang ditemukan

1. **Entity bercampur mapping** — `lib/local/note.dart` punya `toMap/fromMap`;
   `Post` juga bercampur di dalam `post_repository.dart`.
2. **Interface & implementasi satu kelas** — `NoteRepository`/`PostRepository`
   konkret, tanpa kontrak di domain.
3. **DI bocor / tidak terpusat** — provider didefinisikan di `data/providers.dart`
   dan di dalam `lib/pages/settings_page.dart`.

Tidak ditemukan widget yang memanggil `Dio(...)`/`openDatabase` langsung
(project Minggu 5 sudah memakai repository), sehingga fokus refactor adalah
arah dependensi dan pemisahan peran, bukan sekadar memindah folder.

## Step 3 — Struktur target (hasil akhir)

```text
lib/
├── app/
│   └── providers.dart                 # state presentasi lintas fitur (offline toggle)
├── core/
│   ├── failures.dart                  # Failure domain (murni Dart)
│   └── format.dart                    # formatting & parsing (murni Dart)
├── infrastructure/
│   └── database/
│       ├── db.dart                    # opener SQLite (framework)
│       ├── database_factory_io.dart
│       └── database_factory_web.dart
├── features/
│   ├── notes/
│   │   ├── domain/
│   │   │   ├── entities/note.dart
│   │   │   ├── repositories/note_repository.dart      # interface
│   │   │   └── usecases/{get_notes,add_note,update_note,sync_notes}.dart
│   │   ├── data/
│   │   │   ├── models/note_model.dart
│   │   │   └── repositories/note_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/notes_providers.dart
│   │       ├── pages/{notes_page,note_detail_page}.dart
│   │       └── widgets/note_tile.dart
│   ├── posts/
│   │   ├── domain/ (entities/post, repositories/post_repository, usecases/{load_posts,refresh_posts})
│   │   ├── data/ (models/post_model, repositories/post_repository_impl)
│   │   └── presentation/ (providers/posts_providers, widgets/posts_section)
│   └── settings/
│       ├── domain/repositories/prefs_repository.dart
│       ├── data/repositories/prefs_repository_impl.dart
│       └── presentation/ (providers/settings_providers, pages/settings_page)
├── routes.dart
└── main.dart
```

## Peta file lama → tujuan baru

| File lama | Tujuan baru |
|---|---|
| `lib/local/note.dart` | `features/notes/domain/entities/note.dart` (entity) + `features/notes/data/models/note_model.dart` (mapping) |
| `lib/local/db.dart` | `infrastructure/database/db.dart` |
| `lib/local/database_factory_*.dart` | `infrastructure/database/database_factory_*.dart` |
| `lib/data/repositories/note_repository.dart` | `features/notes/domain/repositories/note_repository.dart` + `features/notes/data/repositories/note_repository_impl.dart` |
| `lib/data/repositories/post_repository.dart` | `features/posts/domain/entities/post.dart` + `features/posts/domain/repositories/post_repository.dart` + `features/posts/data/{models,repositories}/*` |
| `lib/data/sync.dart` | `features/notes/domain/usecases/sync_notes.dart` + `features/posts/domain/usecases/{load_posts,refresh_posts}.dart` |
| `lib/data/prefs.dart` | `features/settings/domain/repositories/prefs_repository.dart` + `features/settings/data/repositories/prefs_repository_impl.dart` |
| `lib/data/providers.dart` | `features/notes/presentation/providers/notes_providers.dart`, `features/posts/presentation/providers/posts_providers.dart`, `app/providers.dart` |
| `lib/pages/notes_page.dart` | `features/notes/presentation/pages/notes_page.dart` (+ `posts_section.dart`) |
| `lib/pages/note_detail_page.dart` | `features/notes/presentation/pages/note_detail_page.dart` |
| `lib/pages/settings_page.dart` | `features/settings/presentation/pages/settings_page.dart` (+ `settings_providers.dart`) |
| `lib/widgets/note_tile.dart` | `features/notes/presentation/widgets/note_tile.dart` |
| `lib/router.dart` | `lib/routes.dart` |
| Format tanggal inline | `core/format.dart` |
