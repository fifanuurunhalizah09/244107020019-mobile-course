import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('parse JSON lengkap dengan benar', () {
      final comment = Comment.fromJson({
        'postId': 1,
        'id': 5,
        'name': 'Budi',
        'email': 'budi@mail.com',
        'body': 'Komentar bagus',
      });
      expect(comment.postId, 1);
      expect(comment.id, 5);
      expect(comment.name, 'Budi');
      expect(comment.email, 'budi@mail.com');
      expect(comment.body, 'Komentar bagus');
    });

    test('aman terhadap field yang hilang', () {
      final comment = Comment.fromJson({'id': 7});
      expect(comment.id, 7);
      expect(comment.postId, 0);   // default
      expect(comment.name, '');    // default
      expect(comment.email, '');   // default
      expect(comment.body, '');    // default
    });

    test('aman terhadap null dan field hilang', () {
  final comment = Comment.fromJson({
    'postId': null,
    'id': 2,
    'name': null,
    'email': null,
    'body': null,
  });
  expect(comment.postId, 0);
  expect(comment.id, 2);
  expect(comment.name, '');
  expect(comment.email, '');
  expect(comment.body, '');
});
  });
}