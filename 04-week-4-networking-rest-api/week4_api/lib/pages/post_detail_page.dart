import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/post_detail.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.id, this.loadedPost});
  final int id;
  final Post? loadedPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan objek list bila ID cocok, sehingga tidak ada request berulang.
    final AsyncValue<Post> post = loadedPost?.id == id
        ? AsyncData(loadedPost!)
        : ref.watch(postDetailProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail post $id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali ke daftar',
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: post.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(error)),
              FilledButton(
                onPressed: () => ref.invalidate(postDetailProvider(id)),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (post) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post ${post.id} • User ${post.userId}'),
              const SizedBox(height: 16),
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/post/$id/comments'),
                icon: const Icon(Icons.comment),
                label: const Text('Lihat komentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
