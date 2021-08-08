import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'msg.dart';

class TcpServer {
  final String host = "192.168.2.220";
  final int port = 8888;

  late ServerSocket _server;

  late Socket _client;

  List<int> _recvData = new List<int>.generate(128, (int index) => 0);

  int _recvDataBytes = 0;

  final messages = <Message>[];

  void start() async {
    _server = await ServerSocket.bind(host, port);
    await for (var c in _server) {
      _client = c;
      _recv();
    }
  }

  void _recv() async {
    await for (Uint8List data in _client) {
      print(
          "server[${_client.address.host}:${_client.port}] recv from client[${_client.remoteAddress.host}:${_client.remotePort}], len=${data.lengthInBytes}, data=$data");
      _recvData.replaceRange(_recvDataBytes, data.lengthInBytes, data);
      _recvDataBytes += data.lengthInBytes;
      parseData();
      for (var m in messages) {
        switch (m.optType) {
          case OperationType.opt_echo:
            {
              send(m);
            }
            break;
          case OperationType.opt_ack:
            {}
            break;
          case OperationType.opt_car_status:
            {}
            break;
          default:
            {
              print("Handle message error");
            }
        }
      }
    }
  }

  void parseData() {
    if (_recvDataBytes <= 2) {
      return;
    }

    ByteData data =
        Uint8List.fromList(_recvData).buffer.asByteData(0, _recvDataBytes);
    int packetBytes = data.getUint8(0); // 一个包的长度, 1Byte
    if (_recvDataBytes < packetBytes) {
      return;
    }

    OperationType optType = data.getUint8(1) as OperationType; // 包的操作类型, 1Byte
    switch (optType) {
      case OperationType.opt_echo:
        {
          String echo =
              ByteData.sublistView(data, 2, packetBytes - 2).toString();
          Message msg = new EchoMessage(echo);
          messages.add(msg);
          _recvData.removeRange(0, packetBytes);
          _recvDataBytes -= packetBytes;
          print(msg.toString());
        }
        break;
      case OperationType.opt_ack:
        {
          int ack = data.getUint8(2);
          Message msg = new AckMessage(ack);
          messages.add(msg);
          _recvData.removeRange(0, packetBytes);
          _recvDataBytes -= packetBytes;
          print(msg.toString());
        }
        break;
      case OperationType.opt_car_status:
        {
          int angel = data.getUint16(2);
          MotorRotatingLevel level = data.getUint8(4) as MotorRotatingLevel;
          Message msg = new CarStatusMessage(angel, level);
          messages.add(msg);
          _recvData.removeRange(0, packetBytes);
          _recvDataBytes -= packetBytes;
          print(msg.toString());
        }
        break;
      default:
        {
          print("Parse data error");
        }
    }
  }

  void send(Message data) async {
    try {
      _client.add(data.encode());
      await _client.flush();
    } catch (e) {
      print(e);
    }
  }
}
