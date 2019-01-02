import 'package:flalien/reddit/author.dart';
import 'package:flalien/reddit/basePost.dart';
import 'package:flalien/reddit/comment.dart';
import 'package:flalien/reddit/commentSort.dart';
import 'package:flalien/reddit/postSort.dart';
import 'package:flalien/reddit/postType.dart';
import 'package:http/http.dart' as http;
import 'package:flalien/reddit/post.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class Reddit {
  bool isAuthorized() {
    return false;
  }

  List<String> getDefaultSubreddits() {
    return [
      'announcements',
      'Art',
      'AskReddit',
      'askscience',
      'aww',
      'blog',
      'books',
      'creepy',
      'dataisbeautiful',
      'DIY',
      'Documentaries',
      'EarthPorn',
      'explainlikeimfive',
      'food',
      'funny',
      'Futurology',
      'gadgets',
      'gaming',
      'GetMotivated',
      'gifs',
      'history',
      'IAmA',
      'InternetIsBeautiful',
      'Jokes',
      'LifeProTips',
      'listentothis',
      'mildlyinteresting',
      'movies',
      'Music',
      'news',
      'nosleep',
      'nottheonion',
      'OldSchoolCool',
      'personalfinance',
      'philosophy',
      'photoshopbattles',
      'pics',
      'science',
      'Showerthoughts',
      'space',
      'sports',
      'television',
      'tifu',
      'todayilearned',
      'UpliftingNews',
      'videos',
      'worldnews'
    ];
  }

  Future<List<Post>> getPosts(
      String subreddit, PostSort sort, int postCount) async {
    String stringSort = _getStringValueOfSort(sort);

    List<Post> posts = List<Post>();

    String getUrl =
        'https://www.reddit.com/r/$subreddit/$stringSort/.json?limit=$postCount';

    String response = await _httpGet(getUrl);

    var jsonPosts = jsonDecode(response);

    for (var jsonPost in jsonPosts['data']['children']) {
      final post = jsonPost['data'];

      String id = post['id'];
      String subreddit = post['subreddit_name_prefixed'];
      String title = post['title'];
      Author author = Author(post['author']);
      double createdUtc = post['created_utc'];

      PostType postType;

      if (post['is_self']) {
        postType = PostType.Text;
      } else if (post['post_hint'] == 'link') {
        postType = PostType.Link;
      } else {
        postType = PostType.Media;
      }

      BasePost basePost =
          BasePost(id, subreddit, title, author, createdUtc, postType);

      Post postToAdd;

      if (postType == PostType.Media || postType == PostType.Link) {
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

  Future<List<Comment>> getComments(Post post, CommentSort sort) async {
    String stringSort = _getStringValueOfSort(sort);

    List<Comment> comments = List<Comment>();

    String url =
        'https://www.reddit.com/${post.basePost.subreddit}/comments/${post.basePost.id}.json?sort=$stringSort';

    String response = await _httpGet(url);

    var jsonComments = jsonDecode(response);

    for (var jsonComment in jsonComments[1]['data']['children']) {
      var comment = jsonComment['data'];

      String body = comment['body'];
      Author author = Author(comment['author']);

      if (body != null && author != null) {
        comments.add(Comment(body, author));
      }
    }

    return comments;
  }

  Future<String> _httpGet(String url) async {
    http.Response response = await http.get(url);

    assert(response.statusCode == 200);
    return response.body;
  }

  String _getStringValueOfSort<T>(T sort) {
    String stringSort = sort.toString().split('.').last.toLowerCase();

    return stringSort;
  }

  @Deprecated('Not tested yet, do not use')
  Future<String> _authorizeReddit() async {
    final deviceId = Uuid().v4();
    final clientId = 'SLbS_fAc46zy1Q';
    final password = 'nopassword';
    final url = 'https://www.reddit.com/api/v1/access_token';
    final grantType = 'https://oauth.reddit.com/grants/installed_client';

    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$clientId:$password'));

    http.Response response = await http.post(url,
        body: {'grant_type': grantType, 'device_id': deviceId.toString()},
        headers: {'authorization': basicAuth});

    assert(response.statusCode == 200);
    return response.body;
  }
}
