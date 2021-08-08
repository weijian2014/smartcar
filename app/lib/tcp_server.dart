import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'msg.dart';

class TcpServer {
  late List<Message> messages;

  late Uint8List _recvData;

  void start() async {
    ServerSocket serverSocket = await ServerSocket.bind('192.168.2.220', 8888);
    print("start server....");
    await for (var clientSocket in serverSocket) {
      _recv(clientSocket);
    }
  }

  void _recv(clientSocket) async {
    await for (var data in clientSocket) {
      print("Revc from client, data=$data");
      // todo weijian
      _recvData.add(data);
    }
  }

  void send(Socket socket, data) async {
    sleep(Duration(seconds: 3));
    try {
      socket.add(data);
      await socket.flush();
    } catch (e) {
      print(e);
    }
  }
}
