import 'package:flalien/pages/imagePage.dart';
import 'package:flalien/pages/postPage.dart';
import 'package:flalien/pages/videoPage.dart';
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
    List<Widget> postRow = <Widget>[];

    Function thumbnailCreate;

    if (post.basePost.postType == PostType.Image) {
      thumbnailCreate = _createImageThumbnail;
    } else if (post.basePost.postType == PostType.Video) {
      thumbnailCreate = _createVideoThumbnail;
    } else if (post.basePost.postType == PostType.Link) {
      thumbnailCreate = _createLinkThumbnail;
    }

    if (post.basePost.postType != PostType.Text) {
      Container thumbnail;

      if (post.thumbnail == 'nsfw') {
        thumbnail = thumbnailCreate(
            Text(
              'NSFW',
              style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            post.url);
      } else if (post.thumbnail == 'spoiler') {
        thumbnail = thumbnailCreate(
            Text(
              'SPOILER',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            post.url);
      } else if (post.thumbnail == 'default' || post.thumbnail == 'image') {
        thumbnail = thumbnailCreate(Icon(Icons.link), post.url);
      } else {
        thumbnail = thumbnailCreate(
            ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  post.thumbnail,
                  fit: BoxFit.cover,
                )),
            post.url);
      }

      postRow.add(thumbnail);
    }

    Widget postTitle = Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  post.basePost.title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Container(
                    margin: EdgeInsets.all(3),
                    child: Row(
                      children: _getPostIcons(post),
                    ))
              ],
            )));

    postRow.add(postTitle);

    return Container(
        child: RaisedButton(
      elevation: 0,
      padding: EdgeInsets.only(left: 0, top: 5),
      color: Colors.white,
      onPressed: () => _navigateToPost(post),
      child: Row(children: postRow),
    ));
  }

  List<Widget> _getPostIcons(Post post) {
    List<Widget> icons = [
      _getPostTypeIcon(post.basePost.postType),
    ];

    if (post.basePost.isGilded) {
      icons.add(_getPostGoldIcon());
    }

    return icons;
  }

  Container _getPostGoldIcon() {
    return Container(
        margin: EdgeInsets.only(left: 5),
        child: Icon(FontAwesomeIcons.medal, size: 18, color: Colors.amber));
  }

  Icon _getPostTypeIcon(PostType postType) {
    Icon icon;
    final double size = 18;
    final Color color = Colors.grey;

    switch (postType) {
      case PostType.Text:
        icon = Icon(
          FontAwesomeIcons.comment,
          size: size,
          color: color,
        );
        break;
      case PostType.Link:
        icon = Icon(FontAwesomeIcons.link, size: size, color: color);
        break;
      case PostType.Image:
        icon = Icon(FontAwesomeIcons.image, size: size, color: color);
        break;
      case PostType.Video:
        icon = Icon(FontAwesomeIcons.video, size: size, color: color);
        break;
    }

    return icon;
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
      postWidgetList.add(Divider());
    });

    return postWidgetList;
  }

  Container _createLinkThumbnail(Widget childWidget, String url) {
    var onPressed = () {
      this._launchURL(url);
    };

    return _createBaseThumbnail(childWidget, onPressed);
  }

  Container _createImageThumbnail(Widget childWidget, String url) {
    var onPressed = () {
      Navigator.of(_context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return ImagePage(url);
      }));
    };

    return _createBaseThumbnail(childWidget, onPressed);
  }

  Container _createVideoThumbnail(Widget childWidget, String url) {
    var onPressed = () {
      Navigator.of(_context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return VideoPage(url);
      }));
    };

    return _createBaseThumbnail(childWidget, onPressed);
  }

  Container _createBaseThumbnail(Widget childWidget, Function onPressed) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      height: 70,
      width: 70,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        padding: EdgeInsets.all(0),
        onPressed: onPressed,
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

    return ListView(children: _createPostList());
  }
}
