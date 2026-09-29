import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/paged_posts.dart';
import '../data/network_errors.dart';
import '../widgets/post_tile.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});
  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final state = ref.read(pagedPostsProvider);
      // Error menunggu retry eksplisit, bukan berulang setiap scroll.
      if (state.error == null && _controller.position.extentAfter < 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);
    final notifier = ref.read(pagedPostsProvider.notifier);
    Widget errorPanel(VoidCallback retry) => Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              friendlyErrorMessage(state.error!),
              textAlign: TextAlign.center,
            ),
            FilledButton(onPressed: retry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Paged'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: state.isLoadingMore ? null : notifier.loadFirstPage,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.items.isEmpty
          ? state.error != null
                ? errorPanel(notifier.loadFirstPage)
                : state.isLoadingMore || state.page == 0
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text('Belum ada data dari server.'))
          : ListView.builder(
              controller: _controller,
              itemCount: state.items.length + 1,
              itemBuilder: (context, index) {
                if (index < state.items.length) {
                  return PostTile(post: state.items[index]);
                }
                if (state.error != null) {
                  return errorPanel(notifier.loadNextPage);
                }
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!state.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Semua data termuat.')),
                  );
                }
                // Fallback jika layar terlalu tinggi sehingga list belum scrollable.
                return TextButton(
                  onPressed: notifier.loadNextPage,
                  child: const Text('Muat berikutnya'),
                );
              },
            ),
    );
  }
}
