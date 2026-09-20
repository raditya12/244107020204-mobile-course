import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/stats_page.dart';
import '../pages/todo_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createRouter({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: state.uri.path == '/stats' ? 1 : 0,
          onDestinationSelected: (index) {
            if (index == 0 && state.uri.path != '/') {
              context.go('/');
            } else if (index == 1 && state.uri.path != '/stats') {
              // Push menyimpan halaman daftar agar tombol back dapat kembali.
              context.push('/stats');
            }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.list), label: 'Daftar'),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Statistik',
            ),
          ],
        ),
      ),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const TodoPage()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
      ],
    ),
  ],
);
