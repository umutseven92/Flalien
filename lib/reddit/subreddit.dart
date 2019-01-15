class Subreddit {
  String name;
  String thumbnail;

  String get prefixed {
    return 'r/$name';
  }

  Subreddit(String name) {
    this.name = name;
    thumbnail = "";
  }
}
