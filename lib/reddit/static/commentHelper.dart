
import 'package:flalien/reddit/comment/comment.dart';

class CommentHelper {
  static int countCommentsRecursively(List<Comment> comments) {
    int acc = 0;

    for(var comment in comments) {
      acc += _countChildComments(comment);
    }

    return acc + comments.length;
  }

  static int _countChildComments(Comment comment) {

    int acc = 0;

    for(var childComment in comment.childComments) {
        if(childComment != null && childComment.childComments != null && childComment.childComments.length > 0) {
          acc += _countChildComments(childComment);
        }
    }

    return acc + comment.childComments.length;
  }
}