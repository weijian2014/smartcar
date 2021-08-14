import 'package:flutter/material.dart';

class _ThemeColorData {
  String name;
  ThemeData themeData;

  _ThemeColorData({required this.name, required this.themeData});
}

class ThemeColors {
  static List<_ThemeColorData> _themeColorList = [
    _ThemeColorData(
        name: '暗黑模式', themeData: ThemeData(brightness: Brightness.dark)),
    _ThemeColorData(
        name: '黑色',
        themeData: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          primaryColorLight: Colors.black,
          accentColor: Colors.black,
        )),
    _ThemeColorData(
        name: '红色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.red,
            primaryColorLight: Colors.red,
            accentColor: Colors.red)),
    _ThemeColorData(
        name: '荼色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.teal,
            primaryColorLight: Colors.teal,
            accentColor: Colors.teal)),
    _ThemeColorData(
        name: '粉色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.pink,
            primaryColorLight: Colors.pink,
            accentColor: Colors.pink)),
    _ThemeColorData(
        name: '琥珀色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.amber,
            primaryColorLight: Colors.amber,
            accentColor: Colors.amber)),
    _ThemeColorData(
        name: '橙色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.orange,
            primaryColorLight: Colors.orange,
            accentColor: Colors.orange)),
    _ThemeColorData(
        name: '绿色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.green,
            primaryColorLight: Colors.green,
            accentColor: Colors.green)),
    _ThemeColorData(
        name: '蓝色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            primaryColorLight: Colors.blue,
            accentColor: Colors.blue)),
    _ThemeColorData(
        name: '亮蓝色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.lightBlue,
            primaryColorLight: Colors.lightBlue,
            accentColor: Colors.lightBlue)),
    _ThemeColorData(
        name: '紫色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.purple,
            primaryColorLight: Colors.purple,
            accentColor: Colors.purple)),
    _ThemeColorData(
        name: '深紫色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.deepPurple,
            primaryColorLight: Colors.deepPurple,
            accentColor: Colors.deepPurple)),
    _ThemeColorData(
        name: '靛蓝色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.indigo,
            primaryColorLight: Colors.indigo,
            accentColor: Colors.indigo)),
    _ThemeColorData(
        name: '青色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.cyan,
            primaryColorLight: Colors.cyan,
            accentColor: Colors.cyan)),
    _ThemeColorData(
        name: '棕色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.brown,
            primaryColorLight: Colors.brown,
            accentColor: Colors.brown)),
    _ThemeColorData(
        name: '灰色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.grey,
            primaryColorLight: Colors.grey,
            accentColor: Colors.grey)),
    _ThemeColorData(
        name: '蓝灰色',
        themeData: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blueGrey,
            primaryColorLight: Colors.blueGrey,
            accentColor: Colors.blueGrey)),
  ];

  static int themeCount() => _themeColorList.length;
  static String themeName(int themeIndex) => _themeColorList[themeIndex].name;
  static ThemeData themeData(int themeIndex) =>
      _themeColorList[themeIndex].themeData;
}
