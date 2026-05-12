import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

// 主题与背景设置
class ThemeProvider extends ChangeNotifier {
  int _themeIndex = 0;
  int _particleCount = 15;
  bool _particleEnabled = true;
  double _themeInterval = 2.0;
  bool _autoSwitch = false; // 自动切换开关

  ThemeConfig get theme => HealingThemes.all[_themeIndex];
  int get themeIndex => _themeIndex;
  int get particleCount => _particleCount;
  bool get particleEnabled => _particleEnabled;
  double get themeInterval => _themeInterval;
  bool get autoSwitch => _autoSwitch;

  void setTheme(int index) {
    _themeIndex = index;
    notifyListeners();
  }

  void setParticleCount(int count) {
    _particleCount = count;
    notifyListeners();
  }

  void setParticleEnabled(bool enabled) {
    _particleEnabled = enabled;
    notifyListeners();
  }

  void setThemeInterval(double minutes) {
    _themeInterval = minutes;
    notifyListeners();
  }

  void setAutoSwitch(bool value) {
    _autoSwitch = value;
    notifyListeners();
  }

  // 自动切换到下一个主题
  void switchToNext() {
    _themeIndex = (_themeIndex + 1) % HealingThemes.all.length;
    notifyListeners();
  }
}
