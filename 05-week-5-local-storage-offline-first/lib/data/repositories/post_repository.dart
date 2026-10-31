import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../local/db.dart';

class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  factory Post.fromMap(Map<String, dynamic> map) => Post(
    id: (map['id'] as num).toInt(),
    title: map['title'] as String,
    body: map['body'] as String,
  );
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'body': body};
}

class PostRepository {
  PostRepository({Future<Database> Function()? openDb, Dio? dio})
    : _openDb = openDb ?? openNotesDb,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map(
          (row) => Post.fromMap(
            jsonDecode(row['payload'] as String) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Post>> fetchRemotePosts() async {
    final response = await _dio.get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
    );
    return response.data!
        .map((row) => Post.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCachedPosts(List<Post> posts) async {
    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final post in posts) {
        batch.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(post.toMap()),
          'cached_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
