import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/postType.dart';

class BasePost {
  String id;
  String subreddit;
  String title;
  Author author;
  double createdUtc;
  PostType postType;

  BasePost(this.id, this.subreddit, this.title, this.author, this.createdUtc,
      this.postType);
}
