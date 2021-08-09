import 'dart:io';
import 'dart:typed_data';
import 'msg.dart';

class TcpServer {
  final String host = "192.168.2.102";
  final int port = 8888;

  bool isConnected = false;

  late ServerSocket _server;

  late Socket _client;

  List<int> _recvData = new List<int>.generate(0, (int index) => 0);

  final messages = <Message>[];

  String toString() {
    return "Server[${_server.address.host}:${_server.port}] <-> Client[${_client.remoteAddress.host}:${_client.remotePort}]";
  }

  String getServerInfo() {
    return "Server[${_server.address.host}:${_server.port}]";
  }

  String getClientInfo() {
    if (!isConnected) {
      return "No client connected";
    } else {
      return "Client[${_client.remoteAddress.host}:${_client.remotePort}]";
    }
  }

  void start() async {
    _server = await ServerSocket.bind(host, port);
    await for (var c in _server) {
      isConnected = true;
      _client = c;
      _recv();
    }
  }

  void _recv() async {
    print(
        "Client[${_client.remoteAddress.host}:${_client.remotePort}] connect to server[${_client.address.host}:${_client.port}]");
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
        }
      }

      print(
          "Message handle done, _recvData.len=${_recvData.length}, _recvData=$_recvData");
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
        _recvData.removeRange(orgRecvDataBytes, data.lengthInBytes);
        print(
            "Recv data error, recvDataBytes=$recvDataBytes, packetBytes=$packetBytes, _recvData.len=${_recvData.length}, _recvData=$_recvData");
        break;
      }

      int opt = data.getUint8(1);
      if (opt >= OperationType.opt_max.index) {
        _recvData.removeRange(orgRecvDataBytes, data.lengthInBytes);
        print(
            "Recv data error, operationType=$opt, _recvData.len=${_recvData.length}, _recvData=$_recvData");
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
          "Server[${_client.address.host}:${_client.port}] send to client[${_client.remoteAddress.host}:${_client.remotePort}], $msg");
    } catch (e) {
      print(
          "Server[${_client.address.host}:${_client.port}] send to client[${_client.remoteAddress.host}:${_client.remotePort}], $msg");
    }
  }
}
