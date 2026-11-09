import '../../../../core/failures.dart';

/// Kontrak repository asisten AI.
///
/// Interface berada di domain agar use case dan UI tidak tahu detail
/// penyedia layanan (Gemini, OpenAI, atau mock). Implementasi konkret
/// hidup di layer `data` dan boleh mengimpor Dio.
abstract class AssistantRepository {
  /// Mengirim pertanyaan pengguna dan mengembalikan jawaban AI.
  ///
  /// Kegagalan jaringan/layanan tidak dilempar sebagai exception, tetapi
  /// dikembalikan sebagai [Failure] agar UI mudah menampilkan pesan ramah.
  Future<({String reply, Failure? failure})> ask(String question);
}
