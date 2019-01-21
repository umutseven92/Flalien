import 'package:flalien/reddit/comment/comment.dart';
import 'package:flalien/reddit/comment/commentSort.dart';
import 'package:flalien/reddit/post/post.dart';
import 'package:flalien/reddit/post/postType.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flalien/reddit/static/commentHelper.dart';
import 'package:flalien/reddit/static/sortHelper.dart';
import 'package:flalien/reddit/timeSort.dart';
import 'package:flalien/static/flalienColors.dart';
import 'package:flalien/widgets/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PostPage extends StatefulWidget {
  final Post _post;
  final Reddit _reddit;

  static const int MAX_CHILD_COMMENTS = 3;

  PostPage(this._post, this._reddit);

  @override
  State<StatefulWidget> createState() {
    return PostPageState(_post, _reddit);
  }
}

class PostPageState extends State<PostPage> {
  static const int MAX_LEVELS = 3;
  static const int MAX_CHILD_COMMENTS = 3;

  Post _post;
  Reddit _reddit;
  List<Comment> _comments;
  CommentSort _currentSort;
  TimeSort _currentTimeSort;

  PostPageState(this._post, this._reddit) {
    _currentSort = CommentSort.Best;
    _currentTimeSort = TimeSort.Day;
  }

  List<Widget> _createComments() {
    List<Widget> widgets = <Widget>[];

    List<Widget> comments = _createCommentWidgets(_comments, 0);

    widgets.addAll(comments);

    return widgets;
  }

  List<Widget> _createCommentWidgets(List<Comment> comments, double level) {
    if (level > MAX_LEVELS) {
      return [];
    }

    List<Widget> widgets = <Widget>[];

    for (Comment comment in comments) {
      widgets.add(Container(
          margin: EdgeInsets.only(left: (10 + level * 7), right: 10),
          width: 600,
          child: _createCommentCard(comment)));

      if (comment.childComments.length > 0) {
        List<Widget> childComments = _createCommentWidgets(
            comment.childComments.take(MAX_CHILD_COMMENTS).toList(), level + 1);

        widgets.addAll(childComments);
      }
    }

    return widgets;
  }

  Card _createCommentCard(Comment comment) {
    return Card(
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
              MarkdownBody(data: comment.body)
            ],
          )),
    );
  }

  void _changeTimeSort(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Past hour'),
                onTap: () => _setCurrentTimeSort(TimeSort.Hour),
              ),
              ListTile(
                title: Text('Past day'),
                onTap: () => _setCurrentTimeSort(TimeSort.Day),
              ),
              ListTile(
                title: Text('Past week'),
                onTap: () => _setCurrentTimeSort(TimeSort.Week),
              ),
              ListTile(
                title: Text('Past month'),
                onTap: () => _setCurrentTimeSort(TimeSort.Month),
              ),
              ListTile(
                title: Text('Past year'),
                onTap: () => _setCurrentTimeSort(TimeSort.Year),
              ),
              Container(
                  height: 50,
                  child: ListTile(
                    title: Text('All time'),
                    onTap: () => _setCurrentTimeSort(TimeSort.All),
                  )),
            ],
          );
        });
  }

  void _changeCommentSort(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesomeIcons.clock),
                title: Text('Old'),
                onTap: () => _setCurrentCommentSort(CommentSort.Old),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.star),
                title: Text('Best'),
                onTap: () => _setCurrentCommentSort(CommentSort.Best),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.newspaper),
                title: Text('New'),
                onTap: () => _setCurrentCommentSort(CommentSort.New),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.chartLine),
                title: Text('Top'),
                onTap: () => _setCommentAndTimeSort(CommentSort.Top),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.angry),
                title: Text('Controversial'),
                onTap: () => _setCommentAndTimeSort(CommentSort.Controversial),
              ),
            ],
          );
        });
  }

  void _setCurrentTimeSort(TimeSort timeSort) {
    _currentTimeSort = timeSort;

    _refreshComments();

    Navigator.pop(context);
  }

  void _setCurrentCommentSort(CommentSort sort) {
    _currentSort = sort;

    _refreshComments();

    Navigator.pop(context);
  }

  void _setCommentAndTimeSort(CommentSort postSort) {
    Navigator.pop(context);

    _currentSort = postSort;
    _changeTimeSort(context);
  }

  void _refreshComments() {
    setState(() {
      _comments = null;
    });
    _reddit.getComments(_post, _currentSort, _currentTimeSort).then((result) {
      if (mounted) {
        setState(() {
          this._comments = result;
        });
      }
    });
  }

  @override
  void initState() {
    _reddit.getComments(_post, _currentSort, _currentTimeSort).then((result) {
      if (mounted) {
        setState(() {
          this._comments = result;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var formatter = new DateFormat('MMM d y').add_jms();
    String formattedDate = formatter.format(_post.createdDateTime);

    List<Widget> postInfo = <Widget>[
      Text(_post.basePost.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )),
      Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            '${_post.basePost.author.name}, at $formattedDate',
            style: TextStyle(fontWeight: FontWeight.w500),
          )),
    ];

    if (_post.basePost.postType == PostType.Text) {
      postInfo.add(Container(
          margin: EdgeInsets.only(top: 20),
          child: MarkdownBody(data: _post.body)));
    }

    Container postSection = Container(
      margin: EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: postInfo),
    );

    var fullSection;

    if (_comments == null) {
      fullSection = ListView(
        children: <Widget>[
          postSection,
          Container(
              margin: EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Center(child: LoadingWidget()))
        ],
      );
    } else {
      List<RaisedButton> filters = <RaisedButton>[
        RaisedButton(
            elevation: 0,
            color: Color.fromARGB(0, 10, 10, 10),
            child: Text(
              'Sort: ${SortHelper.getFriendlyStringValueOfSort(_currentSort)}',
              style: TextStyle(color: FlalienColors.mainColor, fontSize: 17),
            ),
            onPressed: () => _changeCommentSort(context))
      ];

      if (_currentSort == CommentSort.Top ||
          _currentSort == CommentSort.Controversial) {
        filters.add(RaisedButton(
            elevation: 0,
            color: Color.fromARGB(0, 10, 10, 10),
            child: Text(
              'Time: ${SortHelper.getFriendlyStringValueOfTimeSort(_currentTimeSort)}',
              style: TextStyle(color: FlalienColors.mainColor, fontSize: 17),
            ),
            onPressed: () => _changeTimeSort(context)));
      }

      Widget commentSorters = Container(
        margin: EdgeInsets.only(left:15),
          child: Row(
        children: filters,
        mainAxisAlignment: MainAxisAlignment.start,
      ));

      Widget commentInfoSection = Container(
          margin: EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Text(
              '${CommentHelper.countCommentsRecursively(_comments)} Comments:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)));

      List<Widget> comments = _createComments();

      fullSection = ListView(
        children: <Widget>[
          postSection,
          Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [commentSorters, commentInfoSection]
                    ..addAll(comments)))
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_post.basePost.subreddit.name),
      ),
      body: fullSection,
      /*
        floatingActionButton:
          FloatingActionButton(
            onPressed: () {},
            child: Icon(FontAwesomeIcons.angleDoubleDown),
            backgroundColor: FlalienColors.mainColor,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
          ),
          */
    );
  }
}
