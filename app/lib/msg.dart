import 'dart:typed_data';

enum OperationType {
  opt_echo, // 用于测试, value = 0
  opt_config, // APP下发配置给小车
  opt_ack, // APP与STM32之间的消息确认
  opt_control, // APP重力感应远程控制小车, 下发角度, 速度等
  opt_car_status, // 小车返回的状态,前进/后退, 马达转速/正向/反向, 舵机方向及角度等等
  opt_max, // value = 5
}

// 马达转转速级别
enum MotorRotatingLevel {
  rpm_stop, // value = 0
  rpm_level_1, // 200rpm
  rpm_level_2, // 400rpm
  rpm_level_3, // 600rpm
  rpm_level_4, // 800rpm
  rpm_level_5, // 1000rpm
  rpm_level_6, // 1200rpm
  rpm_level_7, // 1400rpm
  rpm_level_8, // 1600rpm
  rpm_level_9, // 1800rpm
  rpm_level_10, // 2000rpm
  rpm_max // value = 11
}

abstract class Message {
  int length = 2; // 1Byte
  OperationType optType = OperationType.opt_echo; // 1Byte

  Message(this.length, this.optType);

  int getLength() => this.length;
  OperationType getOperationType() => this.optType;

  Uint8List encode();

  String toString() {
    return "Message: length=[$length], optType=[$optType]";
  }
}

class EchoMessage extends Message {
  String echo;

  EchoMessage(this.echo) : super(echo.length + 2, OperationType.opt_echo);

  @override
  Uint8List encode() {
    ByteData data = ByteData(this.length);
    data.setUint8(0, length);
    data.setUint8(1, optType.index);
    int offset = 2;
    for (var c in this.echo.codeUnits) {
      data.setInt32(offset, c);
      offset *= 4;
    }
    return Uint8List.sublistView(data);
  }

  @override
  String toString() {
    return "EchoMessage: length=[$length], optType=[$optType], echo=[$echo]";
  }
}

class AckMessage extends Message {
  int ack; // 1Byte

  AckMessage(this.ack) : super(3, OperationType.opt_ack);

  @override
  Uint8List encode() {
    ByteData data = ByteData(this.length);
    data.setUint8(0, length);
    data.setUint8(1, optType.index);
    data.setUint8(2, this.ack);
    return Uint8List.sublistView(data);
  }

  @override
  String toString() {
    return "AckMessage: length=[$length], optType=[$optType], ack=[$ack]";
  }
}

class ConfigMessage extends Message {
  int ack; // 1Byte

  ConfigMessage(this.ack) : super(3, OperationType.opt_echo);

  @override
  Uint8List encode() {
    ByteData data = ByteData(this.length);
    data.setUint8(0, length);
    data.setUint8(1, optType.index);
    data.setUint8(2, this.ack);
    return Uint8List.sublistView(data);
  }

  @override
  String toString() {
    return "ConfigMessage: length=[$length], optType=[$optType], ack=[$ack]";
  }
}

class ControlMessage extends Message {
  int angel; // 2Byte

  MotorRotatingLevel level; // 1Byte

  ControlMessage(this.angel, this.level) : super(5, OperationType.opt_control);

  int getAngel() => this.angel;

  MotorRotatingLevel getLevel() => this.level;

  @override
  Uint8List encode() {
    ByteData data = ByteData(this.length);
    data.setUint8(0, length);
    data.setUint8(1, optType.index);
    data.setUint16(2, angel);
    data.setUint8(4, level.index);
    return Uint8List.sublistView(data);
  }

  @override
  String toString() {
    return "ControlMessage: length=[$length], optType=[$optType], angel=[$angel], level=[$level]";
  }
}

class CarStatusMessage extends Message {
  int angel; // 2Byte

  MotorRotatingLevel level; // 1Byte

  CarStatusMessage(this.angel, this.level)
      : super(5, OperationType.opt_car_status);

  int getAngel() => this.angel;

  MotorRotatingLevel getLevel() => this.level;

  @override
  Uint8List encode() {
    ByteData data = ByteData(this.length);
    data.setUint8(0, length);
    data.setUint8(1, optType.index);
    data.setUint16(2, angel);
    data.setUint8(4, level.index);
    return Uint8List.sublistView(data);
  }

  @override
  String toString() {
    return "CarStatusMessage: length=[$length], optType=[$optType], angel=[$angel], level=[$level]";
  }
}
