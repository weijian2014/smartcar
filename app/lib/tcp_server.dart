import 'dart:io';
import 'dart:typed_data';
import 'msg.dart';
import 'my_event_bus.dart';

class _TcpServer {
  //私有构造函数
  _TcpServer._internal();

  //保存单例
  static _TcpServer _singleton = new _TcpServer._internal();

  //工厂构造函数
  factory _TcpServer() => _singleton;

  bool isConnected = false;

  late ServerSocket _server;

  List<Socket> _clients = [];

  List<int> _recvData = new List<int>.generate(0, (int index) => 0);

  final messages = <Message>[];

  void start(String host, int port) async {
    _server = await ServerSocket.bind(host, port);
    bus.fire(new TcpServerEvent(
        "Server[${_server.address.host}:${_server.port}] startup"));
    await for (var client in _server) {
      isConnected = true;
      _clients.add(client);
      bus.fire(new TcpServerEvent(
          "Client[${client.remoteAddress.host}:${client.remotePort}] connect to server[${_server.address.host}:${_server.port}]"));
      _recv(client);
    }
  }

  void _recv(Socket client) async {
    print(
        "Client[${client.remoteAddress.host}:${client.remotePort}] connect to server[${_server.address.host}:${_server.port}]");
    await for (Uint8List data in client) {
      print(
          "Server[${_server.address.host}:${_server.port}] recv from client[${client.remoteAddress.host}:${client.remotePort}], len=${data.lengthInBytes}, data=$data, hex=[${toHex(data)}]");

      _parseData(data);

      for (var msg in messages) {
        switch (msg.optType) {
          case OperationType.opt_echo:
            {
              send(client, msg);
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
      await client.flush();
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

  void send(Socket client, Message msg) async {
    try {
      client.add(msg.encode());
      print(
          "Server[${_server.address.host}:${_server.port}] send to client[${client.remoteAddress.host}:${client.remotePort}], $msg");
    } catch (e) {
      print(
          "Server[${_server.address.host}:${_server.port}] send to client[${client.remoteAddress.host}:${client.remotePort}], $msg");
    }
  }
}

_TcpServer server = new _TcpServer();
