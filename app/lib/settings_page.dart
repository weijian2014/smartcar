import 'package:flutter/material.dart';

class SettingsPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SettingsPageWidgetState();
  }
}

class SettingsPageWidgetState extends State<SettingsPageWidget> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("设置"),
      ),
      body: new Center(
        child: Icon(
          Icons.settings,
          size: 130.0,
          color: Colors.blue,
        ),
      ),
    );
  }
}
