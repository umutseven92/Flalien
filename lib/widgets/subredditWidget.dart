import 'package:flalien/pages/postPage.dart';
import 'package:flalien/reddit/postType.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flutter/material.dart';
import 'package:flalien/reddit/post.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SubredditWidget extends StatelessWidget {
  List<Post> _posts;
  Reddit _reddit;
  BuildContext _context;

  SubredditWidget(this._posts, this._reddit);

  Widget _createPostWidget(Post post) {
    Column arrowColumn = Column(
      children: <Widget>[
        SizedBox(
          height: 40,
          width: 40,
          child: IconButton(
              icon: Icon(
                Icons.arrow_upward,
                color: Colors.grey,
              ),
              onPressed: () => null),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: IconButton(
              icon: Icon(Icons.arrow_downward, color: Colors.grey),
              onPressed: () => null),
        )
      ],
    );

    Expanded postTitle = Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              post.basePost.title,
              style: TextStyle(fontWeight: FontWeight.w600),
            )));

    List<Widget> postRow = <Widget>[];

    if (post.basePost.postType == PostType.Media ||
        post.basePost.postType == PostType.Link) {
      // Add image or video thumbnail

      if (post.thumbnail == 'nsfw') {
        Container thumbnail = _createThumbnail(
            Icon(FontAwesomeIcons.kissWinkHeart, color: Colors.pink), post.url);
        postRow.add(thumbnail);
      } else if (post.thumbnail == 'default') {
        Container thumbnail =
            _createThumbnail(Icon(Icons.link), post.url);
        postRow.add(thumbnail);
      } else {
        Container thumbnail = _createThumbnail(
            ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  post.thumbnail,
                  fit: BoxFit.fill,
                )),
            post.url);
        postRow.add(thumbnail);
      }
    }

    postRow.add(postTitle);

    return Container(
        height: 80,
        child: RaisedButton(
          padding: EdgeInsets.only(left: 0),
          color: Colors.white,
          onPressed: () => _navigateToPost(post),
          child: Row(children: postRow),
        ));
  }

  void _navigateToPost(Post post) {
    Navigator.of(_context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return PostPage(post, _reddit);
    }));
  }

  List<Widget> _createPostList() {
    List<Widget> postWidgetList = List<Widget>();

    _posts.take(50).forEach((post) {
      postWidgetList.add(_createPostWidget(post));
    });

    return postWidgetList;
  }

  Container _createThumbnail(Widget childWidget, String url) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      height: 60,
      width: 60,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        padding: EdgeInsets.all(0),
        onPressed: () => _launchURL(url),
        color: Colors.white,
        child: childWidget,
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Column(
      children: <Widget>[
        Expanded(child: ListView(children: _createPostList()))
      ],
    );
  }
}
