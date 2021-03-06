import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/post/postType.dart';
import 'package:flalien/reddit/subreddit.dart';

class BasePost {
  String id;
  String name;
  Subreddit subreddit;
  String title;
  Author author;
  double createdUtc;
  PostType postType;
  bool isGilded;

  BasePost(this.id, this.name, this.subreddit, this.title, this.author,
      this.createdUtc, this.postType, this.isGilded);
}
