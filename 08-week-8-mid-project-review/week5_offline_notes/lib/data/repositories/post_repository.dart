import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/post.dart';

class PostRepository {
  PostRepository({
    Future<Database> Function()? openDb,
    Dio? dio,
  })  : _openDb = openDb ?? openNotesDb,
        _dio = dio ?? Dio();

  final Future<Database> Function() _openDb;
  final Dio _dio;

  static const _apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  /// Baca dari cache lokal.
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'cached_at DESC');
    return rows.map((row) {
      final json = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      return Post.fromJson(json);
    }).toList();
  }

  /// Fetch dari Dio lalu simpan ke cache.
  Future<List<Post>> refreshPostsInBackground() async {
    final response = await _dio.get<List<dynamic>>(_apiUrl);
    final posts = (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();

    final db = await _openDb();
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (final p in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': p.id,
          'payload': jsonEncode(p.toMap()),
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    return posts;
  }

  /// Alur cache-first (sesuai jobsheet):
  ///   1. Tampilkan cache lokal segera — UI tidak blank saat offline.
  ///   2. Di background: fetch Dio → simpan → invalidate provider.
  Future<List<Post>> loadPostsCacheFirst() async {
    final cached = await readCachedPosts();
    // ignore: unawaited_futures
    refreshPostsInBackground().catchError((_) => <Post>[]);
    return cached;
  }
}