import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_notes/core/failures.dart';
import 'package:week10_ai_notes/features/assistant/domain/usecases/ask_assistant.dart';

import 'helpers/fakes.dart';

void main() {
  test('AskAssistant meneruskan pertanyaan yang sudah di-trim', () async {
    final repo = FakeAssistantRepository(reply: 'Jadwal mulai 08.00.');
    final result = await AskAssistant(repo).call('  Jadwal hari ini?  ');
    expect(result.failure, isNull);
    expect(result.reply, 'Jadwal mulai 08.00.');
    expect(repo.lastQuestion, 'Jadwal hari ini?');
  });

  test(
    'AskAssistant menolak pertanyaan kosong tanpa memanggil repository',
    () async {
      final repo = FakeAssistantRepository();
      final result = await AskAssistant(repo).call('   ');
      expect(result.failure, isA<ValidationFailure>());
      expect(result.reply, isEmpty);
      expect(repo.calls, 0);
    },
  );

  test('AskAssistant meneruskan failure repository tanpa melempar', () async {
    final repo = FakeAssistantRepository(
      reply: '',
      failure: const NetworkFailure('Layanan AI sedang tidak tersedia.'),
    );
    final result = await AskAssistant(repo).call('Halo');
    expect(result.failure, isA<NetworkFailure>());
    expect(result.reply, isEmpty);
    expect(repo.calls, 1);
  });
}
