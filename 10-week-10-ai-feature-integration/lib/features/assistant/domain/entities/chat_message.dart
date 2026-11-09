/// Entity bisnis murni untuk satu pesan pada percakapan dengan asisten AI.
///
/// Tanpa import Flutter/Dio — hanya data yang dibutuhkan UI dan domain.
enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({required this.role, required this.text, required this.at});

  final ChatRole role;
  final String text;
  final DateTime at;
}
