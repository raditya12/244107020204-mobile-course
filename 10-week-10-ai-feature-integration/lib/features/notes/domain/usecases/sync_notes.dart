import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case: mengirim antrean catatan yang belum tersinkron.
///
/// Ini use case yang benar-benar diperlukan karena menggabungkan beberapa
/// operasi repository (baca, urutkan, tandai tersinkron) dan aturan bisnis
/// (urutan berdasarkan `updatedAt`, berhenti bila koneksi dimatikan).
class SyncNotes {
  const SyncNotes(this._repository, {this.upload});

  final NoteRepository _repository;

  /// Simulasi upload ke server. Default: delay satu detik per catatan.
  final Future<void> Function()? upload;

  Future<({int count, Failure? failure})> call({
    required bool Function() isOffline,
  }) async {
    if (isOffline()) {
      return (
        count: 0,
        failure: const NetworkFailure(
          'Mode offline aktif. Sinkronisasi ditunda.',
        ),
      );
    }

    final result = await _repository.fetchNotes();
    if (result.failure != null) {
      return (count: 0, failure: result.failure);
    }

    final dirty = result.notes.where((note) => note.dirty).toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    var synced = 0;
    for (final note in dirty) {
      if (isOffline()) {
        return (
          count: synced,
          failure: const NetworkFailure(
            'Koneksi dinonaktifkan. Antrean tetap disimpan.',
          ),
        );
      }
      try {
        await (upload?.call() ??
            Future<void>.delayed(const Duration(seconds: 1)));
      } catch (e) {
        return (
          count: synced,
          failure: LocalFailure('Gagal mengunggah catatan: $e'),
        );
      }
      if (isOffline()) {
        return (
          count: synced,
          failure: const NetworkFailure('Koneksi dinonaktifkan saat upload.'),
        );
      }
      final marked = await _repository.markSynced(note);
      if (marked.failure != null) {
        return (count: synced, failure: marked.failure);
      }
      synced++;
    }
    return (count: synced, failure: null);
  }
}
