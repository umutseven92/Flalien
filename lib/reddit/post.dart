import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/basePost.dart';
import 'package:flalien/reddit/postType.dart';

class Post {
  BasePost basePost;
  String body;
  String url;
  String thumbnail;

  String get bodyPreview {
    if (body.length > 50) {
      return body.substring(0, 50);
    }
    return body;
  }

  DateTime get createdDateTime {
    final DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        basePost.createdUtc.toInt() * 1000,
        isUtc: true);
    return date;
  }

  Post(this.basePost, this.body, this.url, this.thumbnail);
}
