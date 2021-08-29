import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'config.dart';
import 'theme.dart';
import 'app_provider.dart';
import 'package:provider/provider.dart';
import 'audio.dart';

class SettingsPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SettingsPageWidgetState();
  }
}

class SettingsPageWidgetState extends State<SettingsPageWidget> {
  int _themeIndex = 0;
  bool _isCanVibrate = false;
  bool _isVibration = false;
  bool _isSoundEffect = false;
  int _rotatingLevel = 0;
  bool _isReduceServoSensitivity = false;

  BoxDecoration _setBoxDecoration() {
    if (Provider.of<ThemeState>(context).themeIndex == 0) {
      // 暗黑模式
      return new BoxDecoration(
        border: new Border.all(
          color: Colors.black87,
          width: 1,
        ),
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0.1,
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      );
    } else {
      return new BoxDecoration(
        border: new Border.all(
          color: Colors.grey.withOpacity(0.2), //边框颜色
          width: 1, //边框宽度
        ), // 边色与边宽度
        color: Colors.white, // 底色
        boxShadow: [
          BoxShadow(
            blurRadius: 10, //阴影范围
            spreadRadius: 0.1, //阴影浓度
            color: Colors.grey.withOpacity(0.2), //阴影颜色
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      );
    }
  }

  String _showRotatingLevel(int value) {
    if (value == 0) {
      return "0(自动计算)";
    } else if (value == 1) {
      return "1(100转每分钟)";
    } else {
      return "$value(${(value - 1) * 100 + 70}转每分钟)";
    }
  }

  void _effect() async {
    if (_isSoundEffect) {
      player.play(AudioType.wind_up);
    }

    if (_isCanVibrate && _isVibration) {
      Vibrate.feedback(FeedbackType.heavy);
    }
  }

  @override
  void initState() {
    super.initState();
    Vibrate.canVibrate.then((value) => _isCanVibrate = value);
    _themeIndex = config.themeIndex;
    _isVibration = config.isVibrate;
    _isSoundEffect = config.isSoundEffect;
    _rotatingLevel = config.motroRotatingLevel;
    _isReduceServoSensitivity = config.isReduceServoSensitivity;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("设置"),
        centerTitle: true,
      ),
      body: Theme(
          data: Provider.of<ThemeState>(context).themeData,
          child: ListView(
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text('主题'),
                              ),
                              Expanded(
                                flex: 0,
                                child: Text(
                                    '${ThemeColors.themeName(_themeIndex)}   '),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                            child: Slider(
                              value: _themeIndex.toDouble(),
                              activeColor: Provider.of<ThemeState>(context)
                                  .themeData
                                  .primaryColor,
                              onChanged: (value) {
                                if (value.ceil() != _themeIndex) {
                                  setState(() {
                                    _themeIndex = value.ceil();
                                    _effect();
                                    Provider.of<ThemeState>(context,
                                            listen: false)
                                        .changeTheme(_themeIndex);
                                  });
                                }
                              },
                              onChangeStart: null,
                              onChangeEnd: (data) {
                                config.themeIndex = _themeIndex;
                              },
                              min: 0.0,
                              max: ThemeColors.themeCount() - 1,
                              divisions: ThemeColors.themeCount() - 1,
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.ceil()} dollars}';
                              },
                            ),
                          ),
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
                                onChanged: (value) {
                                  setState(() {
                                    _isVibration = value;
                                    config.isVibrate = _isVibration;
                                    _effect();
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
                                    config.isSoundEffect = _isSoundEffect;
                                    _effect();
                                  });
                                },
                              ),
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text('TCP服务器端口'),
                              ),
                              Expanded(
                                flex: 0,
                                child: Text('${config.tcpServerPort}   '),
                              ),
                            ],
                          )
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
                              activeColor: Provider.of<ThemeState>(context)
                                  .themeData
                                  .primaryColor,
                              onChanged: (value) {
                                if (value.ceil() != _rotatingLevel) {
                                  setState(() {
                                    _rotatingLevel = value.ceil();
                                    _effect();
                                  });
                                }
                              },
                              onChangeStart: null,
                              onChangeEnd: (data) {
                                config.motroRotatingLevel = _rotatingLevel;
                              },
                              min: 0.0,
                              max: 12.0,
                              divisions: 12,
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.ceil()} dollars}';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text('降低舵机灵敏度'),
                            ),
                            Expanded(
                              flex: 0,
                              child: Switch(
                                value: _isReduceServoSensitivity,
                                onChanged: (value) {
                                  setState(() {
                                    _isReduceServoSensitivity = value;
                                    config.isReduceServoSensitivity =
                                        _isReduceServoSensitivity;
                                    _effect();
                                  });
                                },
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
