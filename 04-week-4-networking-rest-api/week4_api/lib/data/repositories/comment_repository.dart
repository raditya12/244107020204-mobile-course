import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Repository menerima client bersama agar konfigurasi dan test terpusat.
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<dynamic>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    // Exception dibiarkan naik agar Riverpod menghasilkan AsyncError.
    final data = response.data;
    // Respons rusak tidak boleh dianggap sukses dengan daftar kosong.
    if (data is! List) {
      throw const FormatException('Expected a comments array');
    }
    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Expected a comment object');
      }
      return Comment.fromJson(item);
    }).toList();
  }
}
