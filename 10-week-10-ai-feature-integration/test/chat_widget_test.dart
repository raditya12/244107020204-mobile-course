import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week10_ai_notes/core/failures.dart';
import 'package:week10_ai_notes/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:week10_ai_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:week10_ai_notes/features/posts/presentation/providers/posts_providers.dart';
import 'package:week10_ai_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:week10_ai_notes/main.dart';

import 'helpers/fakes.dart';

Future<void> _pumpApp(WidgetTester tester, FakeAssistantRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        postRepositoryProvider.overrideWithValue(FakePostRepository()),
        prefsRepositoryProvider.overrideWithValue(FakePrefsRepository()),
        assistantRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('chat menampilkan balasan asisten untuk pertanyaan', (
    tester,
  ) async {
    final repo = FakeAssistantRepository(reply: 'Kantin buka pukul 07.00.');
    await _pumpApp(tester, repo);
    await tester.tap(find.byTooltip('Asisten AI'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chat-input')), 'Kantin buka?');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(find.text('Kantin buka?'), findsOneWidget);
    expect(find.text('Kantin buka pukul 07.00.'), findsOneWidget);
    expect(find.byKey(const Key('chat-error')), findsNothing);
  });

  testWidgets('chat menolak pertanyaan kosong tanpa memanggil AI', (
    tester,
  ) async {
    final repo = FakeAssistantRepository();
    await _pumpApp(tester, repo);
    await tester.tap(find.byTooltip('Asisten AI'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(repo.calls, 0);
    expect(find.byKey(const Key('chat-error')), findsNothing);
  });

  testWidgets('chat menampilkan pesan ramah dan coba lagi saat AI gagal', (
    tester,
  ) async {
    final repo = FakeAssistantRepository(
      reply: '',
      failure: const NetworkFailure('Layanan AI sedang tidak tersedia.'),
    );
    await _pumpApp(tester, repo);
    await tester.tap(find.byTooltip('Asisten AI'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chat-input')), 'Halo');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chat-error')), findsOneWidget);
    expect(find.text('Layanan AI sedang tidak tersedia.'), findsOneWidget);

    // Fallback: coba lagi dengan repository yang kini sukses.
    repo.reply = 'Sudah normal kembali.';
    repo.failure = null;
    await tester.tap(find.byKey(const Key('chat-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chat-error')), findsNothing);
    expect(find.text('Sudah normal kembali.'), findsOneWidget);
  });

  testWidgets('chat diblokir saat mode offline aktif', (tester) async {
    final repo = FakeAssistantRepository();
    await _pumpApp(tester, repo);

    // Toggle offline ada di halaman utama, bukan di halaman chat.
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Asisten AI'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chat-input')), 'Halo');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(repo.calls, 0);
    expect(find.textContaining('Mode offline aktif'), findsWidgets);
    expect(find.byKey(const Key('chat-error')), findsOneWidget);
  });
}
