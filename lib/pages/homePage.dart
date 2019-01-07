import 'package:flalien/reddit/post.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flalien/reddit/static/sortHelper.dart';
import 'package:flalien/widgets/loadingWidget.dart';
import 'package:flalien/widgets/subredditWidget.dart';
import 'package:flalien/reddit/postSort.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  static const String defaultSubreddit = 'all';
  static const int defaultPostCount = 50;

  String _activeSubreddit;
  List<Post> _posts;
  PostSort _currentSort;
  Reddit _reddit;

  HomePageState() {
    _reddit = Reddit();
    _currentSort = PostSort.Hot;
  }

  @override
  void initState() {
    _activeSubreddit = defaultSubreddit;
    _reddit
        .getPosts(_activeSubreddit, _currentSort, defaultPostCount)
        .then((result) {
      setState(() {
        _posts = result;
      });
    });

    super.initState();
  }

  ListTile _createDrawerSubreddit(String subredditName) {
    return ListTile(
      title: Text(subredditName),
      onTap: () {
        _activeSubreddit = subredditName;
        _currentSort = PostSort.Hot;

        setState(() {
          _posts = null;
        });
        _reddit
            .getPosts(subredditName, _currentSort, defaultPostCount)
            .then((result) {
          setState(() {
            _posts = result;
          });
        });

        Navigator.pop(context);
      },
    );
  }

  ListTile _createIconDrawerTile(String title, IconData icon, Function onTap) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Expanded(
            child: Container(
                margin: EdgeInsets.only(left: 10), child: Text(title)),
          )
        ],
      ),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  // Create a drawer with default subreddits & settings
  Drawer _createDrawer() {
    List<Widget> drawerListView = <Widget>[];

    if (_reddit.isAuthorized()) {
    } else {
      drawerListView.add(
        DrawerHeader(
          child: Center(child: Text('Not logged in.')),
        ),
      );

      drawerListView.add(_createDrawerSubreddit('all'));

      _reddit.getDefaultSubreddits().forEach((subreddit) {
        drawerListView.add(_createDrawerSubreddit(subreddit));
      });
    }

    return Drawer(
      child: Column(children: <Widget>[
        Container(
            height: 450,
            child:
                ListView(padding: EdgeInsets.zero, children: drawerListView)),
        Divider(),
        _createIconDrawerTile('Settings', Icons.settings, () {}),
        _createIconDrawerTile('Exit', Icons.exit_to_app, () {}),
      ]),
    );
  }

  void _setCurrentSort(PostSort sort) {
    _currentSort = sort;

    setState(() {
      _posts = null;
    });
    _reddit
        .getPosts(_activeSubreddit, _currentSort, defaultPostCount)
        .then((result) {
      setState(() {
        _posts = result;
      });
    });

    Navigator.pop(context);
  }

  void _changeSort(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesomeIcons.fire),
                title: Text('Hot'),
                onTap: () => _setCurrentSort(PostSort.Hot),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.medal),
                title: Text('Best'),
                onTap: () => _setCurrentSort(PostSort.Best),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.newspaper),
                title: Text('New'),
                onTap: () => _setCurrentSort(PostSort.New),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.star),
                title: Text('Top'),
                onTap: () => _setCurrentSort(PostSort.Top),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.angry),
                title: Text('Controversial'),
                onTap: () => _setCurrentSort(PostSort.Controversial),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var body;

    if (_posts == null) {
      body = Container(
        child: Center(child: LoadingWidget()),
      );
    } else {
      body = Column(
        children: <Widget>[
          Container(
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Sort: ${SortHelper.getStringValueOfSort(_currentSort)}',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => _changeSort(context)),
          ),
          Expanded(child: SubredditWidget(_posts, _reddit))
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(_activeSubreddit),
        ),
        drawer: _createDrawer(),
        body: body);
  }
}
