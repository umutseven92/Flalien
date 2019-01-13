import 'package:flalien/reddit/post.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flalien/reddit/static/sortHelper.dart';
import 'package:flalien/reddit/timeSort.dart';
import 'package:flalien/static/flalienColors.dart';
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
  TimeSort _currentTimeSort;

  Reddit _reddit;

  HomePageState() {
    _reddit = Reddit();
    _currentSort = PostSort.Hot;
    _currentTimeSort = TimeSort.Day;
  }

  @override
  void initState() {
    _activeSubreddit = defaultSubreddit;
    _reddit
        .getPosts(
            _activeSubreddit, _currentSort, defaultPostCount, _currentTimeSort)
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

        _refreshPosts();

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
        // TODO: The following need to be stuck to the bottom
        _createIconDrawerTile('Settings', Icons.settings, () {}),
        _createIconDrawerTile('Exit', Icons.exit_to_app, () {}),
      ]),
    );
  }

  void _setCurrentTimeSort(TimeSort timeSort) {
    _currentTimeSort = timeSort;

    _refreshPosts();

    Navigator.pop(context);
  }

  void _setCurrentPostSort(PostSort sort) {
    _currentSort = sort;

    _refreshPosts();

    Navigator.pop(context);
  }

  void _setPostAndTimeSort(PostSort postSort) {
    Navigator.pop(context);

    _currentSort = postSort;
    _changeTimeSort(context);
  }

  void _refreshPosts() {
    setState(() {
      _posts = null;
    });
    _reddit
        .getPosts(
            _activeSubreddit, _currentSort, defaultPostCount, _currentTimeSort)
        .then((result) {
      setState(() {
        _posts = result;
      });
    });
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

  void _changePostSort(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(FontAwesomeIcons.fire),
                title: Text('Hot'),
                onTap: () => _setCurrentPostSort(PostSort.Hot),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.star),
                title: Text('Best'),
                onTap: () => _setCurrentPostSort(PostSort.Best),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.newspaper),
                title: Text('New'),
                onTap: () => _setCurrentPostSort(PostSort.New),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.chartLine),
                title: Text('Top'),
                onTap: () => _setPostAndTimeSort(PostSort.Top),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.angry),
                title: Text('Controversial'),
                onTap: () => _setPostAndTimeSort(PostSort.Controversial),
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
      List<RaisedButton> filters = <RaisedButton>[
        RaisedButton(
            elevation: 0,
            color: Colors.white,
            child: Text(
              'Sort: ${SortHelper.getFriendlyStringValueOfSort(_currentSort)}',
              style: TextStyle(color: FlalienColors.mainColor, fontSize: 17),
            ),
            onPressed: () => _changePostSort(context))
      ];

      if (_currentSort == PostSort.Top ||
          _currentSort == PostSort.Controversial) {
        filters.add(RaisedButton(
            elevation: 0,
            color: Colors.white,
            child: Text(
              'Time: ${SortHelper.getFriendlyStringValueOfTimeSort(_currentTimeSort)}',
              style: TextStyle(color: FlalienColors.mainColor, fontSize: 17),
            ),
            onPressed: () => _changeTimeSort(context)));
      }

      body = Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(children: filters),
              Expanded(child: SubredditWidget(_posts, _reddit))
            ],
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(_activeSubreddit),
        ),
        drawer: _createDrawer(),
        body: body);
  }
}
