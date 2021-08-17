import 'dart:io';
import 'dart:typed_data';
import 'msg.dart';
import 'my_event_bus.dart';

class _TcpServer {
  bool isStarted = false;

  late ServerSocket _server;

  Map<Socket, List<int>> _clients = new Map();

  final _messages = <Message>[];

  //私有构造函数
  _TcpServer._internal();

  //保存单例
  static _TcpServer _singleton = new _TcpServer._internal();

  //工厂构造函数
  factory _TcpServer() => _singleton;

  void start(String host, int port) async {
    if (isStarted) {
      print(
          "The server[${_server.address.host}:${_server.port}] already started");
      return;
    }

    try {
      // 创建TCP服务器socket
      await ServerSocket.bind(host, port).then((server) async {
        _server = server;
        isStarted = true;
        bus.fire(new TcpServerEvent(
            "Server[${_server.address.host}:${_server.port}] startup"));
      }).catchError((e) {
        print("the tcp server catch error: $e, restarting...");
        _restart(host, port);
        return;
      });
    } catch (e) {
      print("the tcp server bind error: $e, restarting...");
      _restart(host, port);
      return;
    }

    try {
      // 监听TCP服务器socket，等待accept
      await _server.listen((Socket client) async {
        client.setOption(SocketOption.tcpNoDelay, true);
        _clients[client] ??= List.generate(0, (index) => 0);
        bus.fire(new TcpServerEvent(
            "Client[${client.remoteAddress.host}:${client.remotePort}] connect to server[${_server.address.host}:${_server.port}]"));

        _clientListen(client);
      }, onError: (e) {
        // TCP服务器socket监听错误
        print(
            "Server[${_server.address.host}:${_server.port}] onError, $e, restarting...");
        _restart(host, port);
      }, onDone: () {
        print(
            "Server[${_server.address.host}:${_server.port}] onDone, restarting...");
        _restart(host, port);
      }, cancelOnError: false);
    } catch (e) {
      print("the tcp server listen error: $e, restarting...");
      _restart(host, port);
      return;
    }
  }

  void _restart(String host, int port) async {
    for (var c in _clients.entries) {
      await c.key.close();
    }

    _clients.clear();
    await _server.close();
    isStarted = false;
  }

  void _clientListen(Socket client) async {
    try {
      // 监听客户端socket
      await client.listen((Uint8List data) async {
        // 接收到客户端发来的数据data
        var recvData = _clients[client];
        int orgRecvDataBytes = recvData!.length;
        recvData.addAll(data);

        while (true) {
          int recvDataBytes = recvData.length;
          if (recvDataBytes <= 2) {
            break;
          }

          ByteData bd =
              Uint8List.fromList(recvData).buffer.asByteData(0, recvDataBytes);

          // 一个包的长度, 1Byte
          int packetBytes = bd.getUint8(0);
          if (packetBytes > recvDataBytes) {
            recvData.removeRange(orgRecvDataBytes, data.lengthInBytes);
            print(
                "Client[${client.remoteAddress.host}:${client.remotePort}] receive data error, ignore received data");
            break;
          }

          int opt = bd.getUint8(1);
          if (opt >= OperationType.opt_max.index ||
              opt < OperationType.opt_echo.index) {
            recvData.removeRange(orgRecvDataBytes, data.lengthInBytes);
            print(
                "Client[${client.remoteAddress.host}:${client.remotePort}] receive data error, operationType=$opt, ignore received data");
            break;
          }

          // 包的操作类型, 1Byte
          OperationType optType = OperationType.values[opt];

          switch (optType) {
            case OperationType.opt_echo:
              {
                String echo = String.fromCharCodes(
                    Uint8List.sublistView(data, 2, packetBytes));
                Message msg = new EchoMessage(echo);
                _messages.add(msg);
                recvData.removeRange(0, packetBytes);
                // print(msg.toString());
              }
              break;
            case OperationType.opt_ack:
              {
                int ack = bd.getUint8(2);
                Message msg = new AckMessage(ack);
                _messages.add(msg);
                recvData.removeRange(0, packetBytes);
                print(msg.toString());
              }
              break;
            case OperationType.opt_car_status:
              {
                int angel = bd.getUint16(2);
                MotorRotatingLevel level = bd.getUint8(4) as MotorRotatingLevel;
                Message msg = new CarStatusMessage(angel, level);
                _messages.add(msg);
                recvData.removeRange(0, packetBytes);
                print(msg.toString());
              }
              break;
            default:
              {
                print(
                    "Client[${client.remoteAddress.host}:${client.remotePort}] parse data error");
              }
          }
        }

        for (var msg in _messages) {
          switch (msg.optType) {
            case OperationType.opt_echo:
              {
                _send(client, msg);
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
                print(
                    "Client[${client.remoteAddress.host}:${client.remotePort}] handle message error");
              }
          }
        }

        print(
            "Client[${client.remoteAddress.host}:${client.remotePort}] message handle done, _recvData.len=${recvData.length}, recvData=$recvData");
        await client.flush();
        _messages.clear();
      }, onError: (e) async {
        // 监听客户端socket错误
        print(
            "Client[${client.remoteAddress.host}:${client.remotePort}] onError, $e");
        await client.close();
        _closeClient(client);
        return;
      }, onDone: () {
        print(
            "Client[${client.remoteAddress.host}:${client.remotePort}] onDone, closing...");
        _closeClient(client);
      }, cancelOnError: false);
    } catch (e) {
      print(
          "Client[${client.remoteAddress.host}:${client.remotePort}] listen error, $e, closing...");
      _closeClient(client);
    }
  }

  void _closeClient(Socket client) async {
    _clients.remove(client);
    await client.close();
  }

  void _send(Socket client, Message msg) async {
    if (!isStarted) {
      return;
    }

    try {
      client.add(msg.encode());
      print(
          "Server[${_server.address.host}:${_server.port}] send to client[${client.remoteAddress.host}:${client.remotePort}], $msg");
    } catch (e) {
      print(
          "Server[${_server.address.host}:${_server.port}] send to client[${client.remoteAddress.host}:${client.remotePort}], $msg");
      _closeClient(client);
    }
  }

  void sendToAll(Message msg) async {
    if (!isStarted) {
      return;
    }

    var client;
    try {
      for (var entry in _clients.entries) {
        client = entry.key;
        client.add(msg.encode());
        await client.flush();
        print(
            "send to client[${client.remoteAddress.host}:${client.remotePort}], $msg");
      }
    } catch (e) {
      print(
          "Server[${_server.address.host}:${_server.port}] send to all fail, $e");
      _closeClient(client);
    }
  }

  String getServerInfo() {
    if (!isStarted) {
      return "The server has not started";
    } else {
      return "The server listen on ${_server.port}";
    }
  }

  String getClientInfo() {
    if (_clients.isEmpty) {
      return "No client yet";
    } else {
      String info = "";
      int i = 0;
      for (var client in _clients.entries) {
        if (i == 0) {
          info += "${client.key.remoteAddress.host}:${client.key.remotePort}";
        } else {
          info += "\n";
          info +=
              "　　　  ${client.key.remoteAddress.host}:${client.key.remotePort}";
        }
        ++i;
      }
      return info;
    }
  }
}

_TcpServer server = new _TcpServer();
