import 'package:flutter/material.dart';
import 'home_page.dart';
import 'control_page.dart';
import 'settings_page.dart';
import 'tcp_server.dart';
// import 'config.dart';

void main() async {
  // Config.init();
  // print(
  //     'level=${config.getRemoteControlMotroRotatingLevel()}, port=${config.getTcpServerPort()}');
  final String host = "0.0.0.0";
  final int port = 8888;
  server.start(host, port);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SmartCar',
      home: new BottomNavigationWidget(),
    );
  }
}

class BottomNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BottomNavigationWidgetState();
  }
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List pages = <Widget>[
    new HomePageWidget(),
    new ControlPageWidget(),
    new SettingsPageWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        //底部导航栏的创建需要对应的功能标签作为子项，这里我就写了3个，每个子项包含一个图标和一个title。
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: '遥控',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: '设置',
          ),
        ],
        //这是底部导航栏自带的位标属性，表示底部导航栏当前处于哪个导航标签。给他一个初始值0，也就是默认第一个标签页面。
        currentIndex: _currentIndex,
        //这是点击属性，会执行带有一个int值的回调函数，这个int值是系统自动返回的你点击的那个标签的位标
        onTap: (int i) {
          //进行状态更新，将系统返回的你点击的标签位标赋予当前位标属性，告诉系统当前要显示的导航标签被用户改变了。
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }
}
