import 'package:flutter/material.dart';

class _ThemeColorData {
  String name;
  ThemeData themeData;

  _ThemeColorData({required this.name, required this.themeData});
}

class ThemeColors {
  static List<_ThemeColorData> _themeColorList = [
    _ThemeColorData(
        name: '黑色',
        themeData: ThemeData(
            primaryColor: Colors.black, primaryColorLight: Colors.black)),
    _ThemeColorData(
        name: '红色',
        themeData:
            ThemeData(primaryColor: Colors.red, primaryColorLight: Colors.red)),
    _ThemeColorData(
        name: '荼色',
        themeData: ThemeData(
            primaryColor: Colors.teal, primaryColorLight: Colors.teal)),
    _ThemeColorData(
        name: '粉色',
        themeData: ThemeData(
            primaryColor: Colors.pink, primaryColorLight: Colors.pink)),
    _ThemeColorData(
        name: '琥珀色',
        themeData: ThemeData(
            primaryColor: Colors.amber, primaryColorLight: Colors.amber)),
    _ThemeColorData(
        name: '橙色',
        themeData: ThemeData(
            primaryColor: Colors.orange, primaryColorLight: Colors.orange)),
    _ThemeColorData(
        name: '绿色',
        themeData: ThemeData(
            primaryColor: Colors.green, primaryColorLight: Colors.green)),
    _ThemeColorData(
        name: '蓝色',
        themeData: ThemeData(
            primaryColor: Colors.blue, primaryColorLight: Colors.blue)),
    _ThemeColorData(
        name: '亮蓝色',
        themeData: ThemeData(
            primaryColor: Colors.lightBlue,
            primaryColorLight: Colors.lightBlue)),
    _ThemeColorData(
        name: '紫色',
        themeData: ThemeData(
            primaryColor: Colors.purple, primaryColorLight: Colors.purple)),
    _ThemeColorData(
        name: '深紫色',
        themeData: ThemeData(
            primaryColor: Colors.deepPurple,
            primaryColorLight: Colors.deepPurple)),
    _ThemeColorData(
        name: '靛蓝色',
        themeData: ThemeData(
            primaryColor: Colors.indigo, primaryColorLight: Colors.indigo)),
    _ThemeColorData(
        name: '青色',
        themeData: ThemeData(
            primaryColor: Colors.cyan, primaryColorLight: Colors.cyan)),
    _ThemeColorData(
        name: '棕色',
        themeData: ThemeData(
            primaryColor: Colors.brown, primaryColorLight: Colors.brown)),
    _ThemeColorData(
        name: '灰色',
        themeData: ThemeData(
            primaryColor: Colors.grey, primaryColorLight: Colors.grey)),
    _ThemeColorData(
        name: '蓝灰色',
        themeData: ThemeData(
            primaryColor: Colors.blueGrey, primaryColorLight: Colors.blueGrey)),
  ];

  static int themeCount() => _themeColorList.length;
  static String themeName(int themeIndex) => _themeColorList[themeIndex].name;
  static ThemeData themeData(int themeIndex) =>
      _themeColorList[themeIndex].themeData;
}
