import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/comment_providers.dart';
import '../data/network_errors.dart';

/// UI hanya mengamati provider; request dilakukan oleh repository.
class CommentsPage extends ConsumerWidget {
  const CommentsPage({super.key, required this.postId});
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = commentsProvider(postId);
    final comments = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: Text('Komentar post $postId')),
      body: comments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(error), textAlign: TextAlign.center),
                // Invalidate menjalankan build ulang, termasuk state loading.
                FilledButton(
                  onPressed: () => ref.invalidate(provider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Belum ada komentar.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final comment = items[index];
                  return ListTile(
                    title: Text(comment.name),
                    subtitle: Text('${comment.email}\n${comment.body}'),
                    isThreeLine: true,
                  );
                },
              ),
      ),
    );
  }
}
