import 'package:flalien/reddit/post.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flalien/widgets/subredditWidget.dart';
import 'package:flalien/reddit/postSort.dart';
import 'package:flutter/material.dart';

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
  Reddit _reddit;

  HomePageState() {
    _reddit = Reddit();
  }

  @override
  void initState() {
    _activeSubreddit = defaultSubreddit;
    _reddit
        .getPosts(_activeSubreddit, PostSort.Hot, defaultPostCount)
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
        _reddit
            .getPosts(subredditName, PostSort.Hot, defaultPostCount)
            .then((result) {
          setState(() {
            _posts = result;
            _activeSubreddit = subredditName;
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
    return Drawer(
      child: Column(children: <Widget>[
        Container(
            height: 450,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Header'),
                ),
                _createDrawerSubreddit('all'),
                Divider(),
                _createDrawerSubreddit('announcements'),
                _createDrawerSubreddit('art'),
                _createDrawerSubreddit('askreddit'),
                _createDrawerSubreddit('askscience'),
                _createDrawerSubreddit('aww'),
                _createDrawerSubreddit('blog'),
                _createDrawerSubreddit('books'),
                _createDrawerSubreddit('creepy'),
                _createDrawerSubreddit('dataisbeautiful'),
                _createDrawerSubreddit('DIY'),
                _createDrawerSubreddit('Documentaries'),
                _createDrawerSubreddit('EarthPorn'),
                _createDrawerSubreddit('explainlikeimfive'),
                _createDrawerSubreddit('food'),
                _createDrawerSubreddit('funny'),
                _createDrawerSubreddit('futurology'),
                _createDrawerSubreddit('gadgets'),
                _createDrawerSubreddit('gaming'),
                _createDrawerSubreddit('getmotivated'),
                _createDrawerSubreddit('gifs'),
                _createDrawerSubreddit('history'),
                _createDrawerSubreddit('IAma'),
                _createDrawerSubreddit('internetisbeautiful'),
                _createDrawerSubreddit('jokes'),
                _createDrawerSubreddit('lifeprotips'),
                _createDrawerSubreddit('listentothis'),
                _createDrawerSubreddit('mildlyinteresting'),
                _createDrawerSubreddit('movies'),
                _createDrawerSubreddit('music'),
                _createDrawerSubreddit('news'),
                _createDrawerSubreddit('nosleep'),
                _createDrawerSubreddit('nottheonion'),
                _createDrawerSubreddit('oldschoolcool'),
                _createDrawerSubreddit('personalfinance'),
                _createDrawerSubreddit('philosophy'),
                _createDrawerSubreddit('photoshopbattles'),
                _createDrawerSubreddit('pics'),
                _createDrawerSubreddit('science'),
                _createDrawerSubreddit('showerthoughts'),
                _createDrawerSubreddit('space'),
                _createDrawerSubreddit('sports'),
                _createDrawerSubreddit('television'),
                _createDrawerSubreddit('tifu'),
                _createDrawerSubreddit('todayilearned'),
                _createDrawerSubreddit('upliftingnews'),
                _createDrawerSubreddit('videos'),
                _createDrawerSubreddit('worldnews'),
              ],
            )),
        Divider(),
        _createIconDrawerTile('Settings', Icons.settings, () {}),
        _createIconDrawerTile('Exit', Icons.exit_to_app, () {}),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var body;

    if (_posts == null) {
      body = Container(
        child: Center(
          child: Text('Loading..'),
        ),
      );
    } else {
      body = SubredditWidget(_posts, _reddit);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(_activeSubreddit),
        ),
        drawer: _createDrawer(),
        body: body);
  }
}
