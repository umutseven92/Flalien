import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/postType.dart';

class Post {
  String id;
  String subreddit;
  String title;
  String body;
  Author author;
  double createdUtc;
  PostType postType;

  String get bodyPreview {
    if (body.length > 50) {
      return body.substring(0, 50);
    }
    return body;
  }

  DateTime get createdDateTime {
    final DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        createdUtc.toInt() * 1000,
        isUtc: true);
    return date;
  }

  Post(this.id, this.subreddit, this.title, this.body, this.author,
      this.createdUtc, this.postType);
}
