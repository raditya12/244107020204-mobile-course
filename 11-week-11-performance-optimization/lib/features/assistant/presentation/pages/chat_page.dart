import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../providers/assistant_providers.dart';
import '../widgets/message_bubble.dart';

/// Halaman chat dengan asisten AI kampus.
///
/// Widget hanya UI: state dari [chatProvider], aturan di use case,
/// jaringan di repository. Error ditampilkan sebagai kartu ramah dengan
/// opsi coba lagi (fallback design), bukan crash.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).send(text);
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final offline = ref.watch(forceOfflineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Asisten Kampus (AI)')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              if (offline)
                const Material(
                  color: Colors.orange,
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.cloud_off),
                    title: Text(
                      'Mode offline aktif — pertanyaan tidak akan dikirim.',
                    ),
                  ),
                ),
              Expanded(
                child: chat.messages.isEmpty && !chat.loading
                    ? const _EmptyHint()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: chat.messages.length,
                        itemBuilder: (context, index) =>
                            MessageBubble(message: chat.messages[index]),
                      ),
              ),
              if (chat.loading) const LinearProgressIndicator(),
              if (chat.error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    key: const Key('chat-error'),
                    leading: const Icon(Icons.error_outline),
                    title: Text(chat.error!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          key: const Key('chat-retry'),
                          onPressed: () =>
                              ref.read(chatProvider.notifier).retry(),
                          child: const Text('Coba lagi'),
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          onPressed: () =>
                              ref.read(chatProvider.notifier).dismissError(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('chat-input'),
                        controller: _inputController,
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText: 'Tanya apa saja tentang kampus...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: const Key('chat-send'),
                      tooltip: 'Kirim',
                      onPressed: chat.loading ? null : _send,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.smart_toy_outlined, size: 48),
          const SizedBox(height: 8),
          Text(
            'Belum ada percakapan.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'API key diatur di halaman Pengaturan. '
            'Jangan kirim data pribadi ke asisten AI.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
