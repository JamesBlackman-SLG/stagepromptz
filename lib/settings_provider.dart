import 'package:flutter/material.dart' show ChangeNotifier;

import 'settings_service.dart';
import 'settings.dart';

class SettingsProvider with ChangeNotifier {
  final settingsService = SettingsService();

  late Settings _settings = Settings(
    textScaleFactor: 1.0,
  );

  SettingsProvider() {
    loadSettings().then((settings) {
      _settings = settings;
      notifyListeners();
    });
  }

  Settings get settings => _settings;

  Future<void> saveSettings(Settings settings) {
    return settingsService.saveSettings(settings);
  }

  Future<Settings> loadSettings() async {
    return await settingsService.loadSettings();
  }

  void increaseTextScaleFactor() {
    _settings.textScaleFactor += 0.1;
    saveSettings(_settings);
    notifyListeners();
  }

  void decreaseTextScaleFactor() {
    if (_settings.textScaleFactor <= 0.3) return;
    _settings.textScaleFactor -= 0.1;
    saveSettings(_settings);
    notifyListeners();
  }
}
