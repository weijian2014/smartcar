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

  void init() async {
    var r = await rootBundle.loadString('assets/config/config.json');
    _configulation = _Configulation.fromJson(json.decode(r));
    _isInited = true;
  }

  void save() async {
    File file = new File('assets/config/config.json');
    await file.writeAsString(json.encode(_configulation));
  }

  int getTcpServerPort() {
    return _configulation.tcpServerPort;
  }

  void setTcpServerPort(int port) {
    _configulation.tcpServerPort = port;
  }

  int getRemoteControlMotroRotatingLevel() {
    return _configulation.remoteControl.motroRotatingLevel;
  }

  void setRemoteControlMotroRotatingLevel(int level) {
    _configulation.remoteControl.motroRotatingLevel = level;
  }
}

Config config = new Config();

class _Configulation {
  int tcpServerPort = -1;
  late _RemoteControl remoteControl;

  _Configulation({required this.tcpServerPort, required this.remoteControl});

  factory _Configulation.fromJson(Map<String, dynamic> json) {
    return _Configulation(
        tcpServerPort: json['tcp_server_port'],
        remoteControl: _RemoteControl.fromJson(json['remote_control']));
  }
}

class _RemoteControl {
  int motroRotatingLevel = -1;

  _RemoteControl({required this.motroRotatingLevel});

  factory _RemoteControl.fromJson(Map<String, dynamic> json) {
    return _RemoteControl(motroRotatingLevel: json['motro_rotating_level']);
  }
}
