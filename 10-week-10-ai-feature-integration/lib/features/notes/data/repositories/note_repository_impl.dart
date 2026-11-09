import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

/// Implementasi [NoteRepository] memakai SQLite.
///
/// Database opener disuntikkan lewat constructor (DI), bukan dibuat di sini,
/// sehingga repository palsu/in-memory mudah dipasang pada test.
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required this._openDb});

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async {
    try {
      final db = await _openDb();
      final rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return (note: null, failure: null);
      return (note: NoteModel.fromMap(rows.first).toEntity(), failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal membaca catatan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _openDb();
      final now = DateTime.now().toUtc();
      final id = await db.insert(
        'notes',
        NoteModel(
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ).toMap(),
      );
      return (
        note: Note(
          id: id,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan catatan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(
    int id, {
    required String title,
    required String body,
  }) async {
    try {
      final db = await _openDb();
      final now = DateTime.now().toUtc();
      await db.update(
        'notes',
        {
          'title': title,
          'body': body,
          'updated_at': now.toIso8601String(),
          'dirty': 1,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return (
        note: Note(
          id: id,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal mengubah catatan: $e'));
    }
  }

  @override
  Future<({bool ok, Failure? failure})> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (ok: true, failure: null);
    } catch (e) {
      return (ok: false, failure: LocalFailure('Gagal menghapus catatan: $e'));
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await _openDb();
      final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
      );
      return (count: (rows.first['c'] as num).toInt(), failure: null);
    } catch (e) {
      return (count: 0, failure: LocalFailure('Gagal menghitung antrean: $e'));
    }
  }

  /// Hanya bersihkan versi yang benar-benar dikirim. Edit selama upload tetap
  /// dirty.
  @override
  Future<({bool ok, Failure? failure})> markSynced(Note note) async {
    try {
      final db = await _openDb();
      await db.update(
        'notes',
        {'dirty': 0},
        where: 'id = ? AND updated_at = ?',
        whereArgs: [note.id, note.updatedAt.toIso8601String()],
      );
      return (ok: true, failure: null);
    } catch (e) {
      return (
        ok: false,
        failure: LocalFailure('Gagal menandai tersinkron: $e'),
      );
    }
  }
}
