import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../../settings/domain/repositories/prefs_repository.dart';
import '../../domain/repositories/assistant_repository.dart';

/// Implementasi [AssistantRepository] memakai Gemini generateContent API.
///
/// API key dibaca dari repository preferensi (tidak pernah hardcode).
/// System prompt singkat menetapkan persona dan batas jawaban.
class GeminiAssistantRepository implements AssistantRepository {
  GeminiAssistantRepository({
    required this.prefs,
    Dio? dio,
    this.model = 'gemini-2.0-flash',
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models',
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  /// Persona dan batas jawaban sesuai tabel prompt design di jobsheet.
  static const String systemPrompt =
      'Kamu asisten kampus yang ramah. Jawab dalam Bahasa Indonesia, '
      'maksimal 2 kalimat, dan jangan meminta data pribadi pengguna.';

  final PrefsRepository prefs;
  final Dio _dio;
  final String model;
  final String baseUrl;

  @override
  Future<({String reply, Failure? failure})> ask(String question) async {
    final key = await prefs.getApiKey();
    final apiKey = key.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return (
        reply: '',
        failure: const ValidationFailure(
          'API key belum diatur. Isi di halaman Pengaturan.',
        ),
      );
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/$model:generateContent',
        queryParameters: {'key': apiKey},
        data: {
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': question},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 200},
        },
      );
      return extractReply(response.data ?? const {});
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        return (
          reply: '',
          failure: NetworkFailure(
            'API key tidak valid atau tidak memiliki akses (HTTP $status). '
            'Periksa di halaman Pengaturan.',
          ),
        );
      }
      return (
        reply: '',
        failure: NetworkFailure(
          'Layanan AI sedang tidak tersedia. Coba lagi nanti.',
        ),
      );
    }
  }

  /// Menyaring jawaban AI dari payload Gemini.
  ///
  /// Respons bisa saja tidak berisi teks (diblokir keamanan, daftar
  /// `candidates` kosong, atau parts tanpa teks), sehingga parsing harus
  /// defensif dan mengembalikan [Failure], bukan melempar exception.
  ({String reply, Failure? failure}) extractReply(Map<String, dynamic> data) {
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      return (
        reply: '',
        failure: const NetworkFailure(
          'AI tidak memberikan jawaban. Coba pertanyaan lain.',
        ),
      );
    }
    final first = candidates.first;
    final content = first is Map<String, dynamic> ? first['content'] : null;
    final parts = content is Map<String, dynamic> ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) {
      final reason = first is Map<String, dynamic>
          ? first['finishReason']
          : null;
      return (
        reply: '',
        failure: NetworkFailure(
          'AI tidak memberikan jawaban (${reason ?? 'tanpa alasan'}). '
          'Coba lagi atau ganti pertanyaan.',
        ),
      );
    }
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    final text = buffer.toString().trim();
    if (text.isEmpty) {
      return (
        reply: '',
        failure: const NetworkFailure('Jawaban AI kosong. Coba lagi.'),
      );
    }
    return (reply: text, failure: null);
  }
}
