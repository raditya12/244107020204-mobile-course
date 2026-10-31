import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('edge case: null dan tipe salah tidak menyebabkan cast error', () {
    final comment = Comment.fromJson({
      'postId': '1',
      'id': null,
      'name': 42,
      'email': false,
      'body': <String>[],
    });
    expect([comment.postId, comment.id], [0, 0]);
    expect([comment.name, comment.email, comment.body], ['', '', '']);
  });

  test('field valid dipertahankan', () {
    final comment = Comment.fromJson({
      'postId': 1,
      'id': 2,
      'name': 'Nama',
      'email': 'a@example.com',
      'body': 'Komentar',
    });
    expect([comment.postId, comment.id], [1, 2]);
    expect(
      [comment.name, comment.email, comment.body],
      ['Nama', 'a@example.com', 'Komentar'],
    );
  });
  test('fromJson aman ketika field hilang', () {
    // Bukan happy path: seluruh field sengaja dihilangkan.
    final comment = Comment.fromJson({});
    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
