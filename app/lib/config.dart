import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class Config {
  bool _isInited = false;

  late _Configulation _configulation;

  //私有构造函数
  Config._internal();

  //保存单例
  static Config _singleton = new Config._internal();

  //工厂构造函数
  factory Config() => _singleton;

  Future<bool> init() async {
    var conf = await rootBundle.loadString('assets/config/config.json');
    _configulation = new _Configulation.fromJson(json.decode(conf));
    _isInited = true;
    return _isInited;
  }

  void save() async {
    File file = new File('assets/config/config.json');
    await file.writeAsString(json.encode(_configulation));
  }

  int get themeIndex {
    assert(_isInited);
    return _configulation.themeIndex;
  }

  void set themeIndex(int index) {
    assert(_isInited);
    _configulation.themeIndex = index;
  }

  bool get vibration {
    assert(_isInited);
    return _configulation.isVibration;
  }

  void set vibration(bool isVibration) {
    assert(_isInited);
    _configulation.isVibration = isVibration;
  }

  bool get soundEffect {
    assert(_isInited);
    return _configulation.isSoundEffect;
  }

  void set soundEffect(bool isSoundEffect) {
    assert(_isInited);
    _configulation.isSoundEffect = isSoundEffect;
  }

  int get tcpServerPort {
    assert(_isInited);
    return _configulation.tcpServerPort;
  }

  void set tcpServerPort(int port) {
    assert(_isInited);
    _configulation.tcpServerPort = port;
  }

  int get remoteControlMotroRotatingLevel {
    assert(_isInited);
    return _configulation.remoteControl.motroRotatingLevel;
  }

  void set remoteControlMotroRotatingLevel(int level) {
    assert(_isInited);
    _configulation.remoteControl.motroRotatingLevel = level;
  }
}

Config config = new Config();

class _Configulation {
  int themeIndex = 7;
  bool isVibration = false;
  bool isSoundEffect = false;
  int tcpServerPort = -1;
  _RemoteControl remoteControl;

  _Configulation(
      {required this.themeIndex,
      required this.isVibration,
      required this.isSoundEffect,
      required this.tcpServerPort,
      required this.remoteControl});

  factory _Configulation.fromJson(Map<String, dynamic> json) {
    return _Configulation(
        themeIndex: json['theme_index'],
        isVibration: json['vibration'],
        isSoundEffect: json['sound_effect'],
        tcpServerPort: json['tcp_server_port'],
        remoteControl: new _RemoteControl.fromJson(json['remote_control']));
  }
}

class _RemoteControl {
  int motroRotatingLevel = -1;

  _RemoteControl({required this.motroRotatingLevel});

  factory _RemoteControl.fromJson(Map<String, dynamic> json) {
    return _RemoteControl(motroRotatingLevel: json['motro_rotating_level']);
  }
}
