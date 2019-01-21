import 'package:flalien/reddit/author.dart';

class Comment {
  String body;
  Author author;
  List<Comment> childComments;

  Comment(this.body, this.author) {
    childComments = [];
  }
}
