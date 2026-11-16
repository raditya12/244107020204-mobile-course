import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week11_ai_notes/core/rebuild_stats.dart';
import 'package:week11_ai_notes/features/notes/domain/entities/note.dart';
import 'package:week11_ai_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week11_ai_notes/features/posts/domain/entities/post.dart';
import 'package:week11_ai_notes/features/posts/presentation/providers/posts_providers.dart';
import 'package:week11_ai_notes/features/posts/presentation/widgets/posts_section.dart';
import 'package:week11_ai_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:week11_ai_notes/main.dart';

import 'helpers/fakes.dart';

/// Metrik rebuild untuk skenario "toggle mode offline" (Minggu 11).
///
/// Baseline (sebelum optimasi): `{NotesPage: 1, NoteTile: 1, PostsSection: 1}`
/// — seluruh halaman, tile catatan, dan daftar bacaan ikut rebuild.
/// Setelah optimasi (ekstraksi widget + select + provider steril):
/// halaman dan semua tile harus tidak rebuild sama sekali (delta 0);
/// hanya [OfflineCard] dan [PostsHeader] (widget kecil yang memang
/// menampilkan status offline) yang rebuild.
void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required List<Note> notes,
    required List<Post> posts,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(seed: notes),
          ),
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(cached: posts, remote: posts),
          ),
          prefsRepositoryProvider.overrideWithValue(FakePrefsRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('toggle offline tidak me-rebuild halaman dan tile', (
    tester,
  ) async {
    await pumpApp(
      tester,
      notes: [
        Note(
          id: 1,
          title: 'Catatan 1',
          body: 'Isi catatan 1',
          updatedAt: DateTime(2026, 11, 9),
          dirty: true,
        ),
      ],
      posts: List.generate(
        12,
        (i) => Post(id: i + 1, title: 'Bacaan ${i + 1}', body: 'Isi bacaan.'),
      ),
    );

    RebuildStats.reset();
    final before = {
      'NotesPage': RebuildStats.of('NotesPage'),
      'NoteTile': RebuildStats.of('NoteTile'),
      'PostTile': RebuildStats.of('PostTile'),
    };

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final deltas = {
      'NotesPage': RebuildStats.of('NotesPage') - before['NotesPage']!,
      'NoteTile': RebuildStats.of('NoteTile') - before['NoteTile']!,
      'PostTile': RebuildStats.of('PostTile') - before['PostTile']!,
    };
    // ignore: avoid_print
    print('REBUILD_DELTAS_OFFLINE_TOGGLE_AFTER=$deltas');

    expect(find.text('Mode offline aktif'), findsOneWidget);
    expect(deltas['NotesPage'], 0);
    expect(deltas['NoteTile'], 0);
    expect(deltas['PostTile'], 0);
  });

  testWidgets('bacaan dimuat bertahap saat scroll mendekati bawah', (
    tester,
  ) async {
    await pumpApp(
      tester,
      notes: const [],
      posts: List.generate(
        25,
        (i) => Post(id: i + 1, title: 'Bacaan ${i + 1}', body: 'Isi bacaan.'),
      ),
    );

    // Halaman pertama: 10 bacaan, penanda akhir belum muncul.
    expect(find.text('Semua 25 bacaan ditampilkan'), findsNothing);

    // Scroll berulang hingga seluruh halaman termuat (infinite scroll).
    // Spinner pagination beranimasi terus, jadi gunakan pump durasi tetap
    // dan hanya pumpAndSettle setelah seluruh bacaan tampil.
    var allShown = false;
    for (var i = 0; i < 30 && !allShown; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
      await tester.pump(const Duration(milliseconds: 300));
      allShown = find.text('Semua 25 bacaan ditampilkan').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    expect(allShown, isTrue);
    expect(find.text('Semua 25 bacaan ditampilkan'), findsOneWidget);
    expect(find.text('25 bacaan tersimpan di cache'), findsOneWidget);
  });
}
