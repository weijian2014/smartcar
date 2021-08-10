import 'dart:async';
import 'package:event_bus/event_bus.dart';

class _MyEventBus {
  //私有构造函数
  _MyEventBus._internal();

  //保存单例
  static _MyEventBus _singleton = new _MyEventBus._internal();

  //工厂构造函数
  factory _MyEventBus() => _singleton;

  final EventBus _eventBus = new EventBus();

  StreamSubscription<T> listen<T>(f) {
    return _eventBus.on<T>().listen(f);
  }

  void fire(event) {
    _eventBus.fire(event);
  }
}

_MyEventBus bus = new _MyEventBus();

class TcpServerEvent {
  String msg;

  TcpServerEvent(this.msg);
}

class ConnectionStatusEvent {
  String c;

  ConnectionStatusEvent(this.c);
}
