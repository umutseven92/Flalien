import 'package:flutter/material.dart';
import 'package:flalien/pages/homePage.dart';

class FlalienApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flalien',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color.fromARGB(255, 0, 121, 211),
          fontFamily: 'Montserrat',
          iconTheme: IconThemeData(
            color: Color.fromARGB(255, 0, 121, 211),

          )
        ),
        home: HomePage()
    );
  }
}
