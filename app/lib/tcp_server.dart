import 'dart:io';
import 'dart:typed_data';
import 'msg.dart';

class TcpServer {
  final String host = "192.168.2.220";
  final int port = 8888;

  late ServerSocket _server;

  late Socket _client;

  List<int> _recvData = new List<int>.generate(0, (int index) => 0);

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
          "Server[${_client.address.host}:${_client.port}] recv from client[${_client.remoteAddress.host}:${_client.remotePort}], len=${data.lengthInBytes}, data=$data, hex=[${toHex(data)}]");

      _parseData(data);
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
            break;
        }
      }

      await _client.flush();
      messages.clear();
    }
  }

  void _parseData(Uint8List data) async {
    int orgRecvDataBytes = _recvData.length;
    _recvData.addAll(data);
    while (true) {
      int recvDataBytes = _recvData.length;
      if (recvDataBytes <= 2) {
        break;
      }

      ByteData data =
          Uint8List.fromList(_recvData).buffer.asByteData(0, recvDataBytes);
      int packetBytes = data.getUint8(0); // 一个包的长度, 1Byte
      if (packetBytes > recvDataBytes) {
        print(
            "Recv data error, recvDataBytes=$recvDataBytes, packetBytes=$packetBytes");
        _recvData.removeRange(orgRecvDataBytes, data.lengthInBytes);
        break;
      }

      int opt = data.getUint8(1);
      if (opt >= OperationType.opt_max.index) {
        print("Recv data error, operationType=$opt");
        _recvData.removeRange(orgRecvDataBytes, data.lengthInBytes);
        break;
      }

      OperationType optType = OperationType.values[opt]; // 包的操作类型, 1Byte
      switch (optType) {
        case OperationType.opt_echo:
          {
            String echo = String.fromCharCodes(
                Uint8List.sublistView(data, 2, packetBytes));
            Message msg = new EchoMessage(echo);
            messages.add(msg);
            _recvData.removeRange(0, packetBytes);
            // print(msg.toString());
          }
          break;
        case OperationType.opt_ack:
          {
            int ack = data.getUint8(2);
            Message msg = new AckMessage(ack);
            messages.add(msg);
            _recvData.removeRange(0, packetBytes);
            print(msg.toString());
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
            print(msg.toString());
          }
          break;
        default:
          {
            print("Parse data error");
          }
      }
    }
  }

  void send(Message msg) async {
    try {
      _client.add(msg.encode());
      print(
          "server[${_client.address.host}:${_client.port}] send to client[${_client.remoteAddress.host}:${_client.remotePort}], $msg");
    } catch (e) {
      print(
          "server[${_client.address.host}:${_client.port}] send to client[${_client.remoteAddress.host}:${_client.remotePort}], $msg");
    }
  }
}
