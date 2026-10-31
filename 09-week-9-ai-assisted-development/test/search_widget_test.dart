import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week9_ai_notes/features/notes/domain/entities/note.dart';
import 'package:week9_ai_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week9_ai_notes/features/posts/presentation/providers/posts_providers.dart';
import 'package:week9_ai_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:week9_ai_notes/main.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('search menyaring judul dan menampilkan empty state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = FakeNoteRepository(
      seed: [
        Note(
          id: 1,
          title: 'Belanja bulanan',
          body: 'susu telur',
          updatedAt: DateTime(2026, 10, 27),
          dirty: true,
        ),
        Note(
          id: 2,
          title: 'Rapat tim',
          body: 'agenda',
          updatedAt: DateTime(2026, 10, 27),
          dirty: true,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(repository),
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
          prefsRepositoryProvider.overrideWithValue(FakePrefsRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belanja bulanan'), findsOneWidget);
    expect(find.text('Rapat tim'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('notes-search-field')),
      'belanja',
    );
    await tester.pumpAndSettle();
    expect(find.text('Belanja bulanan'), findsOneWidget);
    expect(find.text('Rapat tim'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('notes-search-field')),
      'zzz-tak-ada',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notes-search-empty')), findsOneWidget);
    expect(find.textContaining('Tidak ada catatan yang cocok'), findsOneWidget);

    await tester.tap(find.text('Hapus pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('Belanja bulanan'), findsOneWidget);
    expect(find.text('Rapat tim'), findsOneWidget);
  });
}
