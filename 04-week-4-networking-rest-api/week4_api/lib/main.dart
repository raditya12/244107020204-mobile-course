import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/models/post.dart';
import 'pages/comments_page.dart';
import 'pages/paged_posts_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final routerProvider = Provider<GoRouter>((ref) {
  // Push detail tetap tercermin pada URL browser agar dapat dibagikan.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const PagedPostPage()),
      GoRoute(path: '/posts', builder: (_, _) => const PostListPage()),
      GoRoute(
        path: '/post/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null || id < 1) {
            return const Scaffold(
              body: Center(child: Text('ID post tidak valid.')),
            );
          }
          return PostDetailPage(
            id: id,
            loadedPost: state.extra is Post ? state.extra as Post : null,
          );
        },
      ),
      GoRoute(
        path: '/post/:id/comments',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null || id < 1) {
            return const Scaffold(
              body: Center(child: Text('ID post tidak valid.')),
            );
          }
          return CommentsPage(postId: id);
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Week 4 - REST API',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    routerConfig: ref.watch(routerProvider),
  );
}
