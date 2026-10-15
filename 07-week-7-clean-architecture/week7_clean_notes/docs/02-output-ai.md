# Output awal AI (belum diverifikasi)

Berikut usulan awal asisten. Bagian yang ditandai **OVER-ENGINEERING** adalah
yang kemudian saya tolak atau sederhanakan (lihat `03-verifikasi-ai.md`).

## 1. Struktur feature-first yang diusulkan

```text
lib/
├── core/
│   ├── error/failures.dart
│   ├── error/exceptions.dart
│   ├── network/dio_client.dart
│   ├── usecase/usecase.dart          # base class UseCase<Type, Params>
│   └── utils/format.dart
├── features/
│   ├── notes/
│   │   ├── domain/
│   │   │   ├── entities/note.dart
│   │   │   ├── repositories/note_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_notes.dart
│   │   │       ├── get_note.dart
│   │   │       ├── add_note.dart
│   │   │       ├── update_note.dart
│   │   │       ├── delete_note.dart
│   │   │       ├── count_dirty_notes.dart
│   │   │       └── sync_notes.dart
│   │   ├── data/
│   │   │   ├── datasources/note_local_datasource.dart
│   │   │   ├── models/note_model.dart
│   │   │   └── repositories/note_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/notes_providers.dart
│   │       ├── pages/notes_page.dart
│   │       └── widgets/note_tile.dart
│   ├── posts/
│   │   ├── domain/ (entity, repository, usecases: get_cached_posts, refresh_posts)
│   │   ├── data/ (datasource local+remote, model, repository impl)
│   │   └── presentation/
│   └── settings/
│       ├── domain/ (entity AppPreferences, repository, usecases: get_dark_mode, set_dark_mode)
│       ├── data/ (datasource SharedPreferences, repository impl)
│       └── presentation/
├── app/
│   └── di/providers.dart
└── main.dart
```

## 2. Tujuan tiap file lama

| File lama | Usulan AI |
|---|---|
| `lib/local/note.dart` | pecah: entity → `domain/entities/note.dart`, mapping → `data/models/note_model.dart` |
| `lib/local/db.dart` | pindah ke `core/database/db.dart` |
| `lib/data/repositories/note_repository.dart` | pecah: interface → `domain/repositories`, impl → `data/repositories` |
| `lib/data/repositories/post_repository.dart` | pecah: `Post` → `domain/entities` + `data/models`, repository → interface + impl |
| `lib/data/sync.dart` | pindah ke `domain/usecases/` sebagai `sync_notes.dart` |
| `lib/data/prefs.dart` | pecah: interface → `domain`, impl → `data` |
| `lib/data/providers.dart` | pecah per fitur + `app/di/providers.dart` |
| `lib/pages/*` | pindah ke `features/*/presentation/pages` |
| `lib/widgets/note_tile.dart` | pindah ke `features/notes/presentation/widgets` |
| `lib/router.dart` | pindah ke `lib/routes.dart` |

## 3. Bagian yang ditandai **OVER-ENGINEERING**

- **OVER-ENGINEERING:** base class generik `UseCase<Type, Params>` +
  `NoParams` untuk membungkus use case satu baris.
- **OVER-ENGINEERING:** `datasources` terpisah (local + remote) hanya untuk
  memanggil satu query SQLite / satu endpoint Dio.
- **OVER-ENGINEERING:** `UseCase` untuk tiap CRUD satu baris
  (`GetNote`, `DeleteNote`, `CountDirtyNotes`, `GetDarkMode`, `SetDarkMode`).
- **OVER-ENGINEERING:** entity `AppPreferences` untuk dua nilai primitif.
- **OVER-ENGINEERING:** `core/network/dio_client.dart` padahal hanya ada satu
  pemanggilan Dio.
- **OVER-ENGINEERING:** layer `error/exceptions.dart` terpisah dari `failures.dart`.

## 4. Wiring DI Riverpod yang diusulkan

```dart
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(openDb: openNotesDb),
);
final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
});
```

Usulan DI ini **diterima** (hanya provider Riverpod, tanpa `get_it`).
