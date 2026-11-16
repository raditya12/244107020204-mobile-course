import '../../../../core/failures.dart';
import '../repositories/assistant_repository.dart';

/// Use case: mengirim pertanyaan ke asisten AI.
///
/// Aturan bisnis di sini: pertanyaan tidak boleh kosong dan harus di-trim
/// sebelum dikirim ke repository. Use case murni Dart tanpa Dio/Flutter,
/// sehingga mudah diuji dengan repository palsu.
class AskAssistant {
  const AskAssistant(this._repository);

  final AssistantRepository _repository;

  Future<({String reply, Failure? failure})> call(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return (
        reply: '',
        failure: const ValidationFailure('Pertanyaan tidak boleh kosong.'),
      );
    }
    return _repository.ask(trimmed);
  }
}
