import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean_notes/features/posts/domain/entities/post.dart';
import 'package:week7_clean_notes/features/posts/domain/repositories/post_repository.dart';
import 'package:week7_clean_notes/features/settings/domain/repositories/prefs_repository.dart';

/// Repository catatan palsu untuk pengujian domain murni.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    List<Note>? seed,
    this.fetchFailure,
    this.writeFailure,
    this.deleteFailure,
  }) : _notes = [...?seed];

  final List<Note> _notes;
  final Failure? fetchFailure;
  final Failure? writeFailure;
  final Failure? deleteFailure;

  int _nextId = 100;

  /// Urutan judul yang ditandai tersinkron, untuk memverifikasi ordering.
  final List<String> syncedTitles = [];

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fetchFailure != null) {
      return (notes: const <Note>[], failure: fetchFailure);
    }
    return (notes: List<Note>.unmodifiable(_notes), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async {
    for (final note in _notes) {
      if (note.id == id) return (note: note, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (writeFailure != null) return (note: null, failure: writeFailure);
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      updatedAt: DateTime.now().toUtc(),
      dirty: true,
    );
    _notes.add(note);
    return (note: note, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(
    int id, {
    required String title,
    required String body,
  }) async {
    if (writeFailure != null) return (note: null, failure: writeFailure);
    final index = _notes.indexWhere((note) => note.id == id);
    if (index < 0) return (note: null, failure: null);
    final updated = Note(
      id: id,
      title: title,
      body: body,
      updatedAt: DateTime.now().toUtc(),
      dirty: true,
    );
    _notes[index] = updated;
    return (note: updated, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> deleteNote(int id) async {
    if (deleteFailure != null) return (ok: false, failure: deleteFailure);
    _notes.removeWhere((note) => note.id == id);
    return (ok: true, failure: null);
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    return (count: _notes.where((note) => note.dirty).length, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> markSynced(Note note) async {
    final index = _notes.indexWhere(
      (item) => item.id == note.id && item.updatedAt == note.updatedAt,
    );
    if (index < 0) return (ok: false, failure: null);
    syncedTitles.add(note.title);
    final current = _notes[index];
    _notes[index] = Note(
      id: current.id,
      title: current.title,
      body: current.body,
      updatedAt: current.updatedAt,
      dirty: false,
    );
    return (ok: true, failure: null);
  }
}

/// Repository bacaan palsu untuk pengujian use case cache-first.
class FakePostRepository implements PostRepository {
  FakePostRepository({
    this.cached = const [],
    this.remote = const [],
    this.remoteFailure,
  });

  List<Post> cached;
  final List<Post> remote;
  final Failure? remoteFailure;
  int remoteRequests = 0;
  List<Post>? saved;

  @override
  Future<({List<Post> posts, Failure? failure})> readCachedPosts() async {
    return (posts: cached, failure: null);
  }

  @override
  Future<({List<Post> posts, Failure? failure})> fetchRemotePosts() async {
    remoteRequests++;
    if (remoteFailure != null) {
      return (posts: const <Post>[], failure: remoteFailure);
    }
    return (posts: remote, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> saveCachedPosts(
    List<Post> posts,
  ) async {
    saved = posts;
    cached = posts;
    return (ok: true, failure: null);
  }
}

/// Repository preferensi palsu.
class FakePrefsRepository implements PrefsRepository {
  FakePrefsRepository({this.darkMode = false, this.lastOpened});

  bool darkMode;
  String? lastOpened;
  int markOpenedCalls = 0;

  @override
  Future<({bool darkMode, Failure? failure})> getDarkMode() async {
    return (darkMode: darkMode, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> setDarkMode(bool value) async {
    darkMode = value;
    return (ok: true, failure: null);
  }

  @override
  Future<({String? lastOpened, Failure? failure})> getLastOpened() async {
    return (lastOpened: lastOpened, failure: null);
  }

  @override
  Future<({bool ok, Failure? failure})> markOpenedNow() async {
    markOpenedCalls++;
    lastOpened = DateTime.now().toIso8601String();
    return (ok: true, failure: null);
  }
}
