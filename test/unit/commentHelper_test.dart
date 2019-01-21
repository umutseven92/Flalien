import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/comment/comment.dart';
import 'package:flalien/reddit/static/commentHelper.dart';
import 'package:test/test.dart';

void main() {
  test('Can count comments recursively', () {
    List<Comment> comments = [
      Comment('x', Author('x'))
        ..childComments = [
          Comment('x', Author('x'))
            ..childComments = [
              Comment('x', Author('x')),
              Comment('x', Author('x'))
            ],
          Comment('x', Author('x'))
            ..childComments = [
              Comment('x', Author('x')),
              Comment('x', Author('x'))
                ..childComments = [Comment('x', Author('x'))]
            ]
        ],
      Comment('x', Author('x'))
        ..childComments = [
          Comment('x', Author('x'))
            ..childComments = [
              Comment('x', Author('x'))
                ..childComments = [Comment('x', Author('x'))]
            ]
        ],
      Comment('x', Author('x'))
    ];

    int allCommentsCount = CommentHelper.countCommentsRecursively(comments);

    expect(allCommentsCount, 13);
  });
}
