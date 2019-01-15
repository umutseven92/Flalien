import 'package:flalien/pages/homePage.dart';
import 'package:flalien/reddit/reddit.dart';
import 'package:flalien/reddit/subreddit.dart';
import 'package:flalien/static/flalienColors.dart';
import 'package:flalien/widgets/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPage extends StatefulWidget {
  final Reddit _reddit;

  SearchPage(this._reddit);

  @override
  State<StatefulWidget> createState() {
    return SearchPageState(_reddit);
  }
}

class SearchPageState extends State<SearchPage> {
  static const MAX_SUBREDDIT_CHARS = 20;

  Reddit _reddit;
  bool _loading;
  List<Subreddit> _searchResults;

  final searchTextController = TextEditingController();

  SearchPageState(this._reddit);

  List<ListTile> _createListTilesFromSubreddits() {
    var listTiles = <ListTile>[];

    _searchResults.forEach((subreddit) => listTiles.add(ListTile(
          leading: subreddit.thumbnail == ""
              ? Icon(
                  FontAwesomeIcons.redditAlien,
                  size: 40,
                  color: FlalienColors.mainColor,
                )
              : Image.network(
                  subreddit.thumbnail,
                  height: 40,
                  width: 40,
                ),
          title: Text(subreddit.name),
          onTap: () {
            _navigateToHomePage(context, subreddit);
          },
        )));

    return listTiles;
  }

  void _loadSubreddits() async {
    setState(() {
      _loading = true;
      _searchResults = [];
    });

    _reddit.searchSubreddits(searchTextController.text).then((subreddits) {
      setState(() {
        _loading = false;
        _searchResults = subreddits;
      });
    });
  }

  RaisedButton _buildButton() {
    if (_loading) {
      return RaisedButton(
          child: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: null);
    } else {
      return RaisedButton(
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _loadSubreddits();
        },
      );
    }
  }

  void _navigateToHomePage(BuildContext context, Subreddit subreddit) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return HomePage(subreddit);
    }));
  }

  @override
  void initState() {
    setState(() {
      _searchResults = <Subreddit>[];
      _loading = false;
    });

    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = Container(
          child: Center(
        child: LoadingWidget(),
      ));
    } else {
      body = Expanded(
          child: ListView(
        children: _createListTilesFromSubreddits(),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    maxLength: MAX_SUBREDDIT_CHARS,
                    maxLengthEnforced: true,
                    controller: searchTextController,
                  )),
                  Container(
                      margin: EdgeInsets.only(left: 10, bottom: 10),
                      child: _buildButton())
                ],
              ),
              body
            ],
          )),
    );
  }
}
