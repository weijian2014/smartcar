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

  bool getVibration() {
    assert(_isInited);
    return _configulation.isVibration;
  }

  void setVibration(bool isVibration) {
    assert(_isInited);
    _configulation.isVibration = isVibration;
  }

  bool getSoundEffect() {
    assert(_isInited);
    return _configulation.isSoundEffect;
  }

  void setSoundEffect(bool isSoundEffect) {
    assert(_isInited);
    _configulation.isSoundEffect = isSoundEffect;
  }

  int getTcpServerPort() {
    assert(_isInited);
    return _configulation.tcpServerPort;
  }

  void setTcpServerPort(int port) {
    assert(_isInited);
    _configulation.tcpServerPort = port;
  }

  int getRemoteControlMotroRotatingLevel() {
    assert(_isInited);
    return _configulation.remoteControl.motroRotatingLevel;
  }

  void setRemoteControlMotroRotatingLevel(int level) {
    assert(_isInited);
    _configulation.remoteControl.motroRotatingLevel = level;
  }
}

Config config = new Config();

class _Configulation {
  bool isVibration = false;
  bool isSoundEffect = false;
  int tcpServerPort = -1;
  _RemoteControl remoteControl;

  _Configulation(
      {required this.isVibration,
      required this.isSoundEffect,
      required this.tcpServerPort,
      required this.remoteControl});

  factory _Configulation.fromJson(Map<String, dynamic> json) {
    return _Configulation(
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
