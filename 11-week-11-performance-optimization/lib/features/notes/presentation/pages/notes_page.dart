import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/rebuild_stats.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/providers/posts_providers.dart';
import '../../../posts/presentation/widgets/posts_section.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_actions.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';
import '../widgets/notes_search_field.dart';
import '../widgets/offline_card.dart';

/// Halaman utama: daftar catatan + bacaan API.
///
/// Optimasi Week 11:
/// - body memakai [CustomScrollView] + [SliverList] (lazy: hanya item
///   terlihat yang dibangun) menggantikan ListView(children:);
/// - toggle offline hanya me-rebuild [OfflineCard] dan [PostsHeader],
///   bukan seluruh halaman (ekstraksi widget + Riverpod select);
/// - bacaan API memakai pagination infinite scroll (10 per halaman);
/// - tile dibungkus [RepaintBoundary] agar paint terisolasi.
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  static const int _notesStart = 4;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Pagination: memuat halaman berikutnya saat mendekati ujung daftar.
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    final posts = ref.read(postsProvider).value;
    if (posts != null && posts.isNotEmpty) {
      ref.read(postsPaginationProvider.notifier).loadMore(posts.length);
    }
  }

  /// Bila seluruh konten masih muat di layar (tidak bisa di-scroll),
  /// muat halaman berikutnya agar indikator pagination tetap berlanjut.
  void _autoLoadIfNeeded(List<Post> postsItems, bool hasMore) {
    if (!mounted || !hasMore || postsItems.isEmpty) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) {
      _loadMorePosts();
    }
  }

  Future<void> _edit([Note? note]) async {
    final title = TextEditingController(text: note?.title);
    final body = TextEditingController(text: note?.body);
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Tambah catatan' : 'Edit catatan'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Judul'),
                autofocus: true,
              ),
              TextField(
                controller: body,
                decoration: const InputDecoration(labelText: 'Isi catatan'),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isNotEmpty) Navigator.pop(context, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (save == true) {
      try {
        final failure = note == null
            ? (await ref
                      .read(addNoteProvider)
                      .call(title: title.text, body: body.text))
                  .failure
            : (await ref
                      .read(updateNoteProvider)
                      .call(note.id!, title: title.text, body: body.text))
                  .failure;
        if (failure != null) throw Exception(failure.message);
        ref.invalidate(notesProvider);
        ref.invalidate(dirtyCountProvider);
        if (note != null) ref.invalidate(noteDetailProvider(note.id!));
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan catatan. Coba lagi.'),
            ),
          );
        }
      }
    }
    // Dialog sudah menyelesaikan animasi sebelum controller dilepas.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    title.dispose();
    body.dispose();
  }

  Widget _emptyState(String query) {
    final keyword = query.trim();
    final searching = keyword.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            searching ? Icons.search_off : Icons.note_alt_outlined,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            searching
                ? 'Tidak ada catatan yang cocok dengan "$keyword".'
                : 'Belum ada catatan. Tambahkan catatan, bahkan saat offline.',
            key: searching ? const Key('notes-search-empty') : null,
            textAlign: TextAlign.center,
          ),
          if (searching)
            TextButton(
              onPressed: () =>
                  ref.read(searchQueryProvider.notifier).update(''),
              child: const Text('Hapus pencarian'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    RebuildStats.count('NotesPage');
    final query = ref.watch(searchQueryProvider);
    final notes = ref.watch(searchedNotesProvider);
    final posts = ref.watch(postsProvider);
    final postsVisible = ref.watch(postsPaginationProvider);

    // Blok catatan: loading/error/empty berubah menjadi satu item,
    // selain itu satu item per tile (lazy via SliverList).
    final notesLoading = notes.isLoading;
    final notesHasError = notes.hasError;
    final notesItems = notes.value ?? const <Note>[];
    final notesEmpty = !notesLoading && !notesHasError && notesItems.isEmpty;
    final notesBlock = notesLoading || notesHasError || notesEmpty
        ? 1
        : notesItems.length;

    // Blok bacaan: header selalu tampil; sisanya loading/error/empty/
    // halaman tile + trailing.
    final postsLoading = posts.isLoading;
    final postsHasError = posts.hasError;
    final postsItems = posts.value ?? const <Post>[];
    final postsEmpty = !postsLoading && !postsHasError && postsItems.isEmpty;
    final shownPosts = postsLoading || postsHasError || postsEmpty
        ? 0
        : postsVisible < postsItems.length
        ? postsVisible
        : postsItems.length;
    final hasMorePosts =
        !postsLoading &&
        !postsHasError &&
        !postsEmpty &&
        shownPosts < postsItems.length;
    final postsBlock = postsLoading || postsHasError || postsEmpty
        ? 1
        : shownPosts + 1;
    final notesStart = _notesStart;
    final postsHeaderIndex = notesStart + notesBlock;
    final postsContentStart = postsHeaderIndex + 1;
    final childCount = postsContentStart + postsBlock;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoadIfNeeded(postsItems, hasMorePosts);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: 'Asisten AI',
            onPressed: () => context.push('/chat'),
            icon: const Icon(Icons.smart_toy_outlined),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildItem(
                      context,
                      index: index,
                      notes: notes,
                      notesItems: notesItems,
                      notesLoading: notesLoading,
                      notesHasError: notesHasError,
                      notesEmpty: notesEmpty,
                      query: query,
                      posts: posts,
                      postsItems: postsItems,
                      postsLoading: postsLoading,
                      postsHasError: postsHasError,
                      postsEmpty: postsEmpty,
                      shownPosts: shownPosts,
                      hasMorePosts: hasMorePosts,
                      postsHeaderIndex: postsHeaderIndex,
                      postsContentStart: postsContentStart,
                    ),
                    childCount: childCount,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required int index,
    required AsyncValue<List<Note>> notes,
    required List<Note> notesItems,
    required bool notesLoading,
    required bool notesHasError,
    required bool notesEmpty,
    required String query,
    required AsyncValue<List<Post>> posts,
    required List<Post> postsItems,
    required bool postsLoading,
    required bool postsHasError,
    required bool postsEmpty,
    required int shownPosts,
    required bool hasMorePosts,
    required int postsHeaderIndex,
    required int postsContentStart,
  }) {
    if (index == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Storage & Offline First',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text('Praktikum 1–3 • SharedPreferences + SQLite + Riverpod'),
          const SizedBox(height: 16),
        ],
      );
    }
    if (index == 1) return const OfflineCard();
    if (index == 2) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          NotesSearchField(),
          SizedBox(height: 12),
        ],
      );
    }
    if (index == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Catatan lokal', style: Theme.of(context).textTheme.titleLarge),
          FilledButton.icon(
            onPressed: _edit,
            icon: const Icon(Icons.add),
            label: const Text('Tambah catatan'),
          ),
        ],
      );
    }
    if (index < postsHeaderIndex) {
      final noteIndex = index - _notesStart;
      if (notesLoading) return const LinearProgressIndicator();
      if (notesHasError) {
        return ListTile(
          key: const Key('notes-error'),
          title: const Text('Gagal membaca database.'),
          trailing: TextButton(
            onPressed: () => ref.invalidate(notesProvider),
            child: const Text('Coba lagi'),
          ),
        );
      }
      if (notesEmpty) return _emptyState(query);
      final note = notesItems[noteIndex];
      return NoteTile(
        note: note,
        onOpen: () => context.go('/note/${note.id}'),
        onEdit: () => _edit(note),
        onDelete: () async {
          try {
            await ref.read(notesActionsProvider).delete(note.id!);
          } catch (_) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Gagal menghapus catatan.')),
              );
            }
          }
        },
      );
    }
    if (index == postsHeaderIndex) return const PostsHeader();
    final relative = index - postsContentStart;
    if (postsLoading) return const LinearProgressIndicator();
    if (postsHasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Gagal membaca cache.'),
      );
    }
    if (postsEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Cache kosong. Hubungkan jaringan untuk mengambil bacaan.'),
      );
    }
    if (relative < shownPosts) {
      return PostTile(post: postsItems[relative]);
    }
    // Trailing pagination: penanda statis (bukan spinner beranimasi tak
    // berujung — animasi di luar layar boros CPU/baterai), atau penanda
    // bahwa seluruh cache sudah tampil.
    if (hasMorePosts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Memuat lebih banyak...')),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text('Semua ${postsItems.length} bacaan ditampilkan'),
      ),
    );
  }
}
