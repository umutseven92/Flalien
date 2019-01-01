import 'package:flalien/pages/postPage.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flutter/material.dart';
import 'package:flalien/reddit/post.dart';

class SubredditWidget extends StatelessWidget {
  List<Post> _posts;
  Reddit _reddit;
  BuildContext _context;

  SubredditWidget(this._posts, this._reddit);

  Widget _createPostWidget(Post post) {
    return RaisedButton(
      padding: EdgeInsets.only(left: 0),
      color: Colors.white,
      onPressed: () => _navigateToPost(post),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                height: 30,
                width: 30,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: Colors.grey,
                    ),
                    onPressed: () => null),
              ),
              SizedBox(
                height: 30,
                width: 30,
                child: IconButton(
                    icon: Icon(Icons.arrow_downward, color: Colors.grey),
                    onPressed: () => null),
              )
            ],
          ),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    post.title,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )))
        ],
      ),
    );
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
