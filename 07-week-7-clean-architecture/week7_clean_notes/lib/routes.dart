import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/format.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

/// Konstanta rute agar tidak ada string rute yang tersebar di widget.
class AppRoutes {
  const AppRoutes._();

  static const String notes = '/';
  static const String settings = '/settings';
  static const String noteDetail = '/note/:id';

  static String noteDetailOf(int id) => '/note/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: AppRoutes.notes, builder: (_, _) => const NotesPage()),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(
        path: AppRoutes.noteDetail,
        builder: (_, state) => NoteDetailPage(
          id: parseNoteId(state.pathParameters['id']) ?? -1,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
