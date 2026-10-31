import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_factory_io.dart'
    if (dart.library.js_interop) 'database_factory_web.dart';

/// Dipanggil sekali saat startup untuk menyiapkan factory database per platform.
void initializeStorage() => configureDatabase();

/// Membuka database lokal aplikasi. Fungsi ini disuntikkan ke repository
/// melalui provider DI, sehingga mudah diganti fake saat pengujian.
Future<Database> openNotesDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'offline_notes.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}
