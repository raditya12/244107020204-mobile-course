import 'package:dio/dio.dart';

import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio);
  final Dio _dio;

  /// Deep link mengambil satu post ketika belum ada data list yang dibawa UI.
  Future<Post> fetchPost(int id) async {
    final response = await _dio.get<dynamic>('/posts/$id');
    final data = response.data;
    if (data is! Map<String, dynamic> || data['id'] != id) {
      throw const FormatException('Invalid post response');
    }
    return Post.fromJson(data);
  }

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    final response = await _dio.get<List>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }
}
