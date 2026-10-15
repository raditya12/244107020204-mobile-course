import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week7_clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week7_clean_notes/features/posts/presentation/providers/posts_providers.dart';
import 'package:week7_clean_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:week7_clean_notes/main.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('UI kosong dan toggle offline tidak menghalangi tambah catatan', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
          prefsRepositoryProvider.overrideWithValue(FakePrefsRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum tersinkron: 0'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Mode offline aktif'), findsOneWidget);
    await tester.tap(find.text('Tambah catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan'), findsOneWidget);
  });
}
