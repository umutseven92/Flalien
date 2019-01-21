import 'dart:convert';

import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/post/basePost.dart';
import 'package:flalien/reddit/comment/comment.dart';
import 'package:flalien/reddit/comment/commentSort.dart';
import 'package:flalien/reddit/post/post.dart';
import 'package:flalien/reddit/post/postSort.dart';
import 'package:flalien/reddit/post/postType.dart';
import 'package:flalien/reddit/static/sortHelper.dart';
import 'package:flalien/reddit/subreddit.dart';
import 'package:flalien/reddit/timeSort.dart';
import 'package:http/http.dart' as http;

class Reddit {
  static const int POST_LIMIT = 50;
  static const int COMMENT_LIMIT = 50;

  bool isAuthorized() {
    return false;
  }

  List<Subreddit> getDefaultSubreddits() {
    return [
      Subreddit('announcements'),
      Subreddit('Art'),
      Subreddit('AskReddit'),
      Subreddit('askscience'),
      Subreddit('aww'),
      Subreddit('blog'),
      Subreddit('books'),
      Subreddit('creepy'),
      Subreddit('dataisbeautiful'),
      Subreddit('DIY'),
      Subreddit('Documentaries'),
      Subreddit('EarthPorn'),
      Subreddit('explainlikeimfive'),
      Subreddit('food'),
      Subreddit('funny'),
      Subreddit('Futurology'),
      Subreddit('gadgets'),
      Subreddit('gaming'),
      Subreddit('GetMotivated'),
      Subreddit('gifs'),
      Subreddit('history'),
      Subreddit('IAmA'),
      Subreddit('InternetIsBeautiful'),
      Subreddit('Jokes'),
      Subreddit('LifeProTips'),
      Subreddit('listentothis'),
      Subreddit('mildlyinteresting'),
      Subreddit('movies'),
      Subreddit('Music'),
      Subreddit('news'),
      Subreddit('nosleep'),
      Subreddit('nottheonion'),
      Subreddit('OldSchoolCool'),
      Subreddit('personalfinance'),
      Subreddit('philosophy'),
      Subreddit('photoshopbattles'),
      Subreddit('pics'),
      Subreddit('science'),
      Subreddit('Showerthoughts'),
      Subreddit('space'),
      Subreddit('sports'),
      Subreddit('television'),
      Subreddit('tifu'),
      Subreddit('todayilearned'),
      Subreddit('UpliftingNews'),
      Subreddit('videos'),
      Subreddit('worldnews')
    ];
  }

  Future<List<Post>> getPosts(Subreddit subreddit, PostSort sort,
      TimeSort timeSort, String after) async {
    String stringSort = SortHelper.getStringValueOfSort(sort);

    List<Post> posts = List<Post>();

    String getUrl =
        'https://www.reddit.com/r/${subreddit.name}/$stringSort/.json?limit=$POST_LIMIT';

    if (sort == PostSort.Controversial || sort == PostSort.Top) {
      String stringTimeSort = SortHelper.getStringValueOfSort(timeSort);

      getUrl += '&t=$stringTimeSort';
    }

    if (after != null) {
      getUrl += '&after=$after';
    }

    String response = await _httpGet(getUrl);

    var jsonPosts = jsonDecode(response);

    for (var jsonPost in jsonPosts['data']['children']) {
      final post = jsonPost['data'];

      String id = post['id'];
      String name = post['name'];
      Subreddit subreddit = Subreddit(post['subreddit_name_prefixed']);
      String title = post['title'];
      Author author = Author(post['author']);
      double createdUtc = post['created_utc'];

      PostType postType;

      if (post['is_self']) {
        postType = PostType.Text;
      } else if (post['is_video']) {
        postType = PostType.Video;
      } else if (post['post_hint'] == 'link') {
        postType = PostType.Link;
      } else if (post['post_hint'] == 'image') {
        postType = PostType.Image;
      } else {
        postType = PostType.Link;
      }

      var gildCount = post['gilded'];

      BasePost basePost = BasePost(id, name, subreddit, title, author,
          createdUtc, postType, gildCount > 0);

      Post postToAdd;

      if (postType != PostType.Text) {
        String thumbnail = post['thumbnail'];
        String url = post['url'];

        postToAdd = Post(basePost, null, url, thumbnail);
      } else {
        String body = post['selftext'];

        postToAdd = Post(basePost, body, null, null);
      }

      posts.add(postToAdd);
    }

    return posts;
  }

  Future<List<Comment>> getComments(Post post, CommentSort sort, TimeSort timeSort) async {
    String stringSort = SortHelper.getStringValueOfSort(sort);

    String url =
        'https://www.reddit.com/${post.basePost.subreddit.name}/comments/${post.basePost.id}.json?sort=$stringSort';

    if (sort == CommentSort.Controversial || sort == CommentSort.Top) {
      String stringTimeSort = SortHelper.getStringValueOfSort(timeSort);

      url += '&t=$stringTimeSort';
    }

    String response = await _httpGet(url);

    var jsonComments = jsonDecode(response);

    return parseComments(jsonComments);

  }

  List<Comment> parseComments(dynamic jsonComments) {
    List<Comment> comments = List<Comment>();

    for (var jsonComment in jsonComments[1]['data']['children']) {
      var commentJson = jsonComment['data'];
      Comment comment = _parseComment(commentJson);

      if(comment != null) {
        comments.add(comment);
      }
    }

    return comments;
  }

  Comment _parseComment(dynamic commentJson) {
    String body = commentJson['body'];
    Author author = Author(commentJson['author']);

    Comment comment = Comment(body, author);

    var replies = commentJson['replies'];


    if(replies != '' && replies != [] && replies != null) {
      var children = replies['data']['children'];

      for(var reply in children) {
        var childCommentJson = reply['data'];
        Comment childComment = _parseComment(childCommentJson);

        if(childComment != null) {
          comment.childComments.add(childComment);
        }
      }
    }

    if (body != null && author != null) {
      return comment;
    } else {
      return null;
    }
  }

  Future<List<Subreddit>> searchSubreddits(String query,
      {bool includeNSFW = true}) async {
    List<Subreddit> subreddits = List<Subreddit>();

    String url =
        'https://www.reddit.com/subreddits/search.json?q=$query&include_over_18=on';

    String response = await _httpGet(url);

    var jsonSubreddits = jsonDecode(response);

    for (var jsonSubreddit in jsonSubreddits['data']['children']) {
      var subreddit = jsonSubreddit['data'];

      String name = subreddit['display_name'];
      String pic = subreddit['community_icon'];

      if(pic == "") {
        pic = subreddit['icon_img'];
      }

      subreddits.add(Subreddit(name)..thumbnail = pic);
    }

    return subreddits;
  }

  Future<String> _httpGet(String url) async {
    http.Response response = await http.get(url);

    assert(response.statusCode == 200);
    return response.body;
  }
}
