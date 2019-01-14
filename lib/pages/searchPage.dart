import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  static const MAX_SUBREDDIT_CHARS = 20;

  List<ListTile> _searchResults;

  @override
  void initState() {
    setState(() {
      _searchResults = <ListTile>[];
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Column(
            children: <Widget>[
              TextField(
                maxLength: MAX_SUBREDDIT_CHARS,
                maxLengthEnforced: true,
              ),
              Expanded(
                  child: ListView(
                children: _searchResults,
              ))
            ],
          )),
    );
  }
}
