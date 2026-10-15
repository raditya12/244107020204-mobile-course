import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

/// Implementasi [PostRepository] memakai SQLite (cache) + Dio (jaringan).
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({required this._openDb, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Future<Database> Function() _openDb;
  final Dio _dio;

  @override
  Future<({List<Post> posts, Failure? failure})> readCachedPosts() async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final posts = rows
          .map(
            (row) => PostModel.fromMap(
              jsonDecode(row['payload'] as String) as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
      return (posts: posts, failure: null);
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: LocalFailure('Gagal membaca cache bacaan: $e'),
      );
    }
  }

  @override
  Future<({List<Post> posts, Failure? failure})> fetchRemotePosts() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://jsonplaceholder.typicode.com/posts',
      );
      final posts = response.data!
          .map((row) => PostModel.fromMap(row as Map<String, dynamic>).toEntity())
          .toList();
      return (posts: posts, failure: null);
    } on DioException catch (e) {
      return (
        posts: const <Post>[],
        failure: NetworkFailure('Gagal mengambil bacaan: ${e.message}'),
      );
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: NetworkFailure('Gagal mengambil bacaan: $e'),
      );
    }
  }

  @override
  Future<({bool ok, Failure? failure})> saveCachedPosts(List<Post> posts) async {
    try {
      final db = await _openDb();
      await db.transaction((txn) async {
        await txn.delete('cached_posts');
        final batch = txn.batch();
        for (final post in posts) {
          batch.insert('cached_posts', {
            'id': post.id,
            'payload': jsonEncode(
              PostModel(id: post.id, title: post.title, body: post.body).toMap(),
            ),
            'cached_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
        await batch.commit(noResult: true);
      });
      return (ok: true, failure: null);
    } catch (e) {
      return (ok: false, failure: LocalFailure('Gagal menyimpan cache: $e'));
    }
  }
}
