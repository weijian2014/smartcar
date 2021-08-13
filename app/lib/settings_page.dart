import 'package:flutter/material.dart';
import 'config.dart';

class SettingsPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SettingsPageWidgetState();
  }
}

class SettingsPageWidgetState extends State<SettingsPageWidget> {
  bool _isVibration = false;
  bool _isSoundEffect = false;
  double _tcpServerPort = 8888.0;
  double _rotatingLevel = 0.0;

  BoxDecoration _setBoxDecoration() {
    return new BoxDecoration(
      border: Border.all(
          color: Color.fromRGBO(200, 220, 220, 220),
          width: 3,
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

  String _showRotatingLevel(double value) {
    int v = value.ceil();
    if (v == 0) {
      return "0(自动计算)";
    } else {
      return "$v(${v * 200}转每分钟)";
    }
  }

  @override
  void initState() {
    super.initState();
    _isVibration = config.getVibration();
    _isSoundEffect = config.getSoundEffect();
    _tcpServerPort = config.getTcpServerPort().toDouble();
    _rotatingLevel = config.getRemoteControlMotroRotatingLevel().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("设置"),
          centerTitle: true,
          // backgroundColor: Color(0xFF363644)
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
                              // activeColor: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  _isVibration = value;
                                  config.setVibration(_isVibration);
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
                              // activeColor: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  _isSoundEffect = value;
                                  config.setSoundEffect(_isSoundEffect);
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
                              child: Text('${_tcpServerPort.round()}   '),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                          child: Slider(
                            value: _tcpServerPort,
                            onChanged: (value) {
                              setState(() {
                                _tcpServerPort = value;
                              });
                            },
                            onChangeStart: null,
                            onChangeEnd: (data) {
                              config.setTcpServerPort(_tcpServerPort.ceil());
                            },
                            min: 8866.0,
                            max: 8888.0,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey,
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.round()} dollars}';
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
                            value: _rotatingLevel,
                            onChanged: (value) {
                              setState(() {
                                _rotatingLevel = value;
                              });
                            },
                            onChangeStart: null,
                            onChangeEnd: (data) {
                              config.setRemoteControlMotroRotatingLevel(
                                  _rotatingLevel.ceil());
                            },
                            min: 0.0,
                            max: 10.0,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey,
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
