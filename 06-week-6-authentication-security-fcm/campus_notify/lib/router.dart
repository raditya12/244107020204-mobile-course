import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == Routes.login;
      if (!loggedIn && !goingLogin) return Routes.login;
      if (loggedIn && goingLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: Routes.announcement,
        builder: (_, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );

  // Perbarui guard setiap status auth berubah (login/logout/refresh).
  ref.listen(authStateProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
