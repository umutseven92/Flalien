import 'package:flalien/pages/imagePage.dart';
import 'package:flalien/pages/postPage.dart';
import 'package:flalien/pages/videoPage.dart';
import 'package:flalien/reddit/post/post.dart';
import 'package:flalien/reddit/post/postSort.dart';
import 'package:flalien/reddit/post/postType.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flalien/reddit/static/sortHelper.dart';
import 'package:flalien/reddit/timeSort.dart';
import 'package:flalien/static/flalienColors.dart';
import 'package:flalien/widgets/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  static const String defaultSubreddit = 'all';

  BuildContext _context;
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
        .getPosts(_activeSubreddit, _currentSort, _currentTimeSort, null)
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
      child:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Flexible(
            child:
                ListView(padding: EdgeInsets.zero, children: drawerListView)),
        Divider(),
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
        .getPosts(_activeSubreddit, _currentSort, _currentTimeSort, null)
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
      padding: EdgeInsets.only(left: 0, top: 5, right: 5),
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

    if (_activeSubreddit == defaultSubreddit) {
      icons.add(_getSubredditChip(post.basePost.subreddit));
    }

    return icons;
  }

  Expanded _getSubredditChip(String subredditName) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.only(right: 5),
            child: Text(
              subredditName,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.end,
            )));
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

      var loading = false;

      body = Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(children: filters, mainAxisAlignment: MainAxisAlignment.start,),
              Expanded(child: ListView.builder(itemBuilder: (context, i) {
                if (i.isOdd) {
                  return Divider();
                }

                final index = i ~/ 2;

                if (index >= _posts.length && !loading) {
                  loading = true;

                  String last = _posts.last.basePost.name;
                  _reddit
                      .getPosts(_activeSubreddit, _currentSort,
                          _currentTimeSort, last)
                      .then((result) {
                    setState(() {
                      loading = false;
                      _posts.addAll(result);
                    });
                  });
                }

                if (_posts.length > index) {
                  return _createPostWidget(_posts[index]);
                } else {
                  return Center(child: LoadingWidget());
                }
              }))
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
