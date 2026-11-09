import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../app/providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/repositories/gemini_assistant_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../domain/usecases/ask_assistant.dart';

/// Wiring DI fitur `assistant`.
///
/// Data layer: repository Gemini menerima Dio (bisa diganti fake saat test).
final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return GeminiAssistantRepository(
    prefs: ref.watch(prefsRepositoryProvider),
    dio: Dio(),
  );
});

final askAssistantProvider = Provider<AskAssistant>(
  (ref) => AskAssistant(ref.watch(assistantRepositoryProvider)),
);

/// State halaman chat: riwayat pesan, status loading, dan pesan error ramah.
class ChatState {
  const ChatState({
    this.messages = const [],
    this.loading = false,
    this.error,
    this.lastQuestion,
  });

  final List<ChatMessage> messages;
  final bool loading;
  final String? error;

  /// Pertanyaan terakhir agar tombol "Coba lagi" bisa mengirim ulang.
  final String? lastQuestion;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
    String? lastQuestion,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: error,
      lastQuestion: lastQuestion ?? this.lastQuestion,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  Future<void> send(String question) async {
    if (state.loading) return;
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: ChatRole.user, text: trimmed, at: now),
      ],
      loading: true,
      lastQuestion: trimmed,
    );

    // Fallback offline: mode forceOffline memblokir panggilan jaringan.
    if (ref.read(forceOfflineProvider)) {
      state = state.copyWith(
        loading: false,
        error: 'Mode offline aktif. Matikan mode offline untuk bertanya.',
      );
      return;
    }

    final result = await ref.read(askAssistantProvider).call(trimmed);
    if (result.failure != null) {
      state = state.copyWith(loading: false, error: result.failure!.message);
      return;
    }
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: ChatRole.assistant, text: result.reply, at: now),
      ],
      loading: false,
    );
  }

  Future<void> retry() async {
    final last = state.lastQuestion;
    if (last == null) return;
    // Hapus pesan user terakhir agar tidak dobel saat dikirim ulang.
    final messages = [...state.messages]..removeLast();
    state = state.copyWith(messages: messages);
    await send(last);
  }

  void dismissError() {
    state = state.copyWith(error: null);
  }
}
