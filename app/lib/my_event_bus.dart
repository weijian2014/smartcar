import 'dart:async';
import 'package:event_bus/event_bus.dart';

class MyEventBus {
  //私有构造函数
  MyEventBus._internal();

  //保存单例
  static MyEventBus _singleton = new MyEventBus._internal();

  //工厂构造函数
  factory MyEventBus() => _singleton;

  final EventBus _eventBus = new EventBus();

  StreamSubscription<T> listen<T>(f) {
    return _eventBus.on<T>().listen(f);
  }

  void fire(event) {
    _eventBus.fire(event);
  }
}

MyEventBus bus = new MyEventBus();

class TcpServerStatusEvent {
  String s;

  TcpServerStatusEvent(this.s);
}

class ConnectionStatusEvent {
  String c;

  ConnectionStatusEvent(this.c);
}
