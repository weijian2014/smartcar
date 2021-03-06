import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';

class HomePageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageWidgetState();
  }
}

class HomePageWidgetState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("首页"),
        ),
        body: Theme(
          data: Provider.of<ThemeState>(context).themeData,
          child: new Center(
            child: Icon(
              Icons.home,
              size: 130.0,
              color: Provider.of<ThemeState>(context).themeData.primaryColor,
            ),
          ),
        ));
  }
}
