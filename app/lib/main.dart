import 'package:flutter/material.dart';
import 'home_page.dart';
import 'control_page.dart';
import 'settings_page.dart';
import 'tcp_server.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';

void main() async {
  // 此处要等待Flutter初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  config.init().then((ok) {
    // 此处要等待加载配置完成
    server.start("0.0.0.0", config.tcpServerPort);
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ThemeState()),
    ], child: BottomNavigationWidget());
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
  int _currentIndex = 1;
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
    return MaterialApp(
        title: '智能小车',
        theme: Provider.of<ThemeState>(context).themeData,
        // darkTheme: Provider.of<ThemeState>(context).themeData, 这里不需要
        home: new Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor:
                Provider.of<ThemeState>(context).themeData.primaryColor,
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
            currentIndex: _currentIndex,
            onTap: (int i) {
              setState(() {
                _currentIndex = i;
              });
            },
          ),
        ));
  }
}
