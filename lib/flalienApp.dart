import 'package:flalien/pages/homePage.dart';
import 'package:flalien/reddit/subreddit.dart';
import 'package:flalien/static/flalienColors.dart';
import 'package:flutter/material.dart';

class FlalienApp extends StatelessWidget {
  final Subreddit defaultSubreddit = Subreddit('all');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flalien',
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: FlalienColors.mainColor,
            fontFamily: 'Montserrat',
            iconTheme: IconThemeData(color: FlalienColors.mainColor),
            buttonTheme: ButtonThemeData(buttonColor: FlalienColors.mainColor)),
        home: HomePage(defaultSubreddit));
  }
}
