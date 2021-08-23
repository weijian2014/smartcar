import 'package:shared_preferences/shared_preferences.dart';

class _AppConfig {
  bool inInit = false;

  late SharedPreferences _prefs;

  //私有构造函数
  _AppConfig._internal();

  //保存单例
  static _AppConfig _singleton = new _AppConfig._internal();

  //工厂构造函数
  factory _AppConfig() => _singleton;

  Future<bool> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    inInit = true;
    return inInit;
  }

  int get themeIndex {
    assert(inInit);
    return _prefs.getInt('themeIndex') ?? 0;
  }

  void set themeIndex(int index) {
    assert(inInit);
    _prefs.setInt('themeIndex', index);
  }

  bool get isVibrate {
    assert(inInit);
    return _prefs.getBool('isVibrate') ?? false;
  }

  void set isVibrate(bool isVibrate) {
    assert(inInit);
    _prefs.setBool('isVibrate', isVibrate);
  }

  bool get isSoundEffect {
    assert(inInit);
    return _prefs.getBool('isSoundEffect') ?? true;
  }

  void set isSoundEffect(bool isVibrate) {
    assert(inInit);
    _prefs.setBool('isSoundEffect', isVibrate);
  }

  int get tcpServerPort {
    assert(inInit);
    return _prefs.getInt('tcpServerPort') ?? 8888;
  }

  void set tcpServerPort(int port) {
    assert(inInit);
    _prefs.setInt('tcpServerPort', port);
  }

  int get motroRotatingLevel {
    assert(inInit);
    return _prefs.getInt('motroRotatingLevel') ?? 0;
  }

  void set motroRotatingLevel(int level) {
    assert(inInit);
    _prefs.setInt('motroRotatingLevel', level);
  }

  bool get isReduceServoSensitivity {
    assert(inInit);
    return _prefs.getBool('isReduceServoSensitivity') ?? false;
  }

  void set isReduceServoSensitivity(bool isReduceServoSensitivity) {
    assert(inInit);
    _prefs.setBool('isReduceServoSensitivity', isReduceServoSensitivity);
  }
}

_AppConfig config = new _AppConfig();
