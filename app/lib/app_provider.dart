import 'package:flutter/material.dart';
import 'theme.dart';

class ThemeState with ChangeNotifier {
  int _themeIndex = 7;

  void changeTheme(int themeIndex) {
    _themeIndex = themeIndex;
    notifyListeners();
  }

  ThemeData get themeData => ThemeColors.themeData(_themeIndex);
  String get themeName => ThemeColors.themeName(_themeIndex);
  int get themeIndex => _themeIndex;
}
