import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const NotesPage()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
      GoRoute(
        path: '/note/:id',
        builder: (_, state) => NoteDetailPage(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
