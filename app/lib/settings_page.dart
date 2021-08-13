import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'config.dart';

class SettingsPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SettingsPageWidgetState();
  }
}

class SettingsPageWidgetState extends State<SettingsPageWidget> {
  final List<Color> themeList = [
    Colors.black,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.lightBlue,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey
  ];

  int _themeColorIndex = 7;
  bool _isCanVibrate = false;
  bool _isVibration = false;
  bool _isSoundEffect = false;
  int _tcpServerPort = 8888;
  int _rotatingLevel = 0;

  BoxDecoration _setBoxDecoration() {
    return new BoxDecoration(
      border: Border.all(
          // color: Color.fromRGBO(200, 220, 220, 220),
          width: 1,
          style: BorderStyle.solid),
      borderRadius: BorderRadius.circular(20),
      // boxShadow: [
      //   BoxShadow(
      //     offset: Offset(0, 0),
      //     color: Color.fromRGBO(200, 220, 220, 220),
      //     blurRadius: 5,
      //     spreadRadius: 0,
      //   )]
    );
  }

  String _showRotatingLevel(int value) {
    if (value == 0) {
      return "0(自动计算)";
    } else {
      return "$value(${value * 200}转每分钟)";
    }
  }

  void _vibrate(FeedbackType type) {
    if (_isCanVibrate && _isVibration) {
      Vibrate.feedback(type);
    }
  }

  @override
  void initState() {
    super.initState();
    Vibrate.canVibrate.then((value) => _isCanVibrate = value);
    _themeColorIndex = config.getThemeColorIndex();
    _isVibration = config.getVibration();
    _isSoundEffect = config.getSoundEffect();
    _tcpServerPort = config.getTcpServerPort();
    _rotatingLevel = config.getRemoteControlMotroRotatingLevel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("设置"),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(5),
              decoration: _setBoxDecoration(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('全局配置',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text('振动'),
                          ),
                          Expanded(
                            flex: 0,
                            child: Switch(
                              value: _isVibration,
                              onChanged: (value) {
                                setState(() {
                                  _isVibration = value;
                                  config.setVibration(_isVibration);
                                  _vibrate(FeedbackType.success);
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text('音效'),
                          ),
                          Expanded(
                            flex: 0,
                            child: Switch(
                              value: _isSoundEffect,
                              onChanged: (value) {
                                setState(() {
                                  _isSoundEffect = value;
                                  config.setSoundEffect(_isSoundEffect);
                                  _vibrate(FeedbackType.success);
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text('服务器端口'),
                            ),
                            Expanded(
                              flex: 0,
                              child: Text('${_tcpServerPort}   '),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                          child: Slider(
                            value: _tcpServerPort.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _tcpServerPort = value.ceil();
                                _vibrate(FeedbackType.success);
                              });
                            },
                            onChangeStart: null,
                            onChangeEnd: (data) {
                              config.setTcpServerPort(_tcpServerPort);
                            },
                            min: 8866.0,
                            max: 8888.0,
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.ceil()} dollars}';
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              decoration: _setBoxDecoration(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('远程控制',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text('马达转速等级'),
                            ),
                            Expanded(
                              flex: 0,
                              child: Text(
                                  '${_showRotatingLevel(_rotatingLevel)}   '),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                          child: Slider(
                            value: _rotatingLevel.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _rotatingLevel = value.ceil();
                                _vibrate(FeedbackType.success);
                              });
                            },
                            onChangeStart: null,
                            onChangeEnd: (data) {
                              config.setRemoteControlMotroRotatingLevel(
                                  _rotatingLevel);
                            },
                            min: 0.0,
                            max: 10.0,
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.ceil()} dollars}';
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
