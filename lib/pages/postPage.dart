import 'package:flalien/reddit/comment.dart';
import 'package:flalien/reddit/commentSort.dart';
import 'package:flalien/reddit/post.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostPage extends StatefulWidget {
  final Post _post;
  final Reddit _reddit;

  PostPage(this._post, this._reddit);

  @override
  State<StatefulWidget> createState() {
    return PostPageState(_post, _reddit);
  }
}

class PostPageState extends State<PostPage> {
  Post _post;
  Reddit _reddit;
  List<Comment> _comments;

  PostPageState(this._post, this._reddit);

  List<Widget> _createComments() {
    List<Widget> widgets = <Widget>[];

    widgets.add(Text('Comments',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)));

    _comments.take(50).forEach((comment) {
      widgets.add(Container(
          width: 600,
          child: Card(
            child: Container(
                padding: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      comment.author.name,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(comment.body)
                  ],
                )),
          )));
    });

    return widgets;
  }

  @override
  void initState() {
    _reddit.getComments(_post, CommentSort.Best).then((result) {
      setState(() {
        this._comments = result;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var formatter = new DateFormat('MMMd y').add_jms();
    String formattedDate = formatter.format(_post.createdDateTime);

    var body;

    if (_comments == null) {
      body = ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${_post.author.name}, at $formattedDate',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 20), child: Text(_post.body))
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Center(
                child: Text('Loading..'),
              ))
        ],
      );
    } else {
      body = ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    )),
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      '${_post.author.name}, at $formattedDate',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 20), child: Text(_post.body))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _createComments()),
          )
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(_post.subreddit),
        ),
        body: body);
  }
}
