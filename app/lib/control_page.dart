import 'package:flutter/material.dart';

class ControlPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ControlPageWidgetState();
  }
}

class ControlPageWidgetState extends State<ControlPageWidget> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("遥控"),
      ),
      body: new Center(
        child: Icon(
          Icons.control_camera,
          size: 130.0,
          color: Colors.blue,
        ),
      ),
    );
  }
}
