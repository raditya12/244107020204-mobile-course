import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_notes/core/failures.dart';
import 'package:week10_ai_notes/features/assistant/data/repositories/gemini_assistant_repository.dart';
import 'package:week10_ai_notes/features/settings/domain/repositories/prefs_repository.dart';

/// Repository preferensi minimal khusus untuk membangun instance repository.
class _StubPrefs implements PrefsRepository {
  @override
  Future<({bool darkMode, Failure? failure})> getDarkMode() async =>
      (darkMode: false, failure: null);

  @override
  Future<({bool ok, Failure? failure})> setDarkMode(bool value) async =>
      (ok: true, failure: null);

  @override
  Future<({String? lastOpened, Failure? failure})> getLastOpened() async =>
      (lastOpened: null, failure: null);

  @override
  Future<({bool ok, Failure? failure})> markOpenedNow() async =>
      (ok: true, failure: null);

  @override
  Future<({String? apiKey, Failure? failure})> getApiKey() async =>
      (apiKey: 'stub-key', failure: null);

  @override
  Future<({bool ok, Failure? failure})> setApiKey(String value) async =>
      (ok: true, failure: null);
}

GeminiAssistantRepository _repo() =>
    GeminiAssistantRepository(prefs: _StubPrefs());

void main() {
  test('extractReply membaca teks dari respons normal', () {
    final result = _repo().extractReply({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': '  Jadwal kampus mulai 08.00.  '},
            ],
          },
        },
      ],
    });
    expect(result.failure, isNull);
    expect(result.reply, 'Jadwal kampus mulai 08.00.');
  });

  test('extractReply mengembalikan failure bila candidates kosong', () {
    final result = _repo().extractReply({'candidates': []});
    expect(result.reply, isEmpty);
    expect(result.failure, isA<NetworkFailure>());
  });

  test('extractReply mengembalikan failure bila jawaban diblokir', () {
    final result = _repo().extractReply({
      'candidates': [
        {'finishReason': 'SAFETY'},
      ],
    });
    expect(result.reply, isEmpty);
    expect(result.failure, isA<NetworkFailure>());
  });

  test('extractReply mengembalikan failure bila semua parts tanpa teks', () {
    final result = _repo().extractReply({
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'inlineData': {'mimeType': 'image/png'},
              },
            ],
          },
        },
      ],
    });
    expect(result.reply, isEmpty);
    expect(result.failure, isA<NetworkFailure>());
  });
}
