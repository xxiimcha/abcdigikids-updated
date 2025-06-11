import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/music.service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isMusicOn = true;
  bool _isParentalControlOn = false; // ✅ New property

  final MusicService _musicService = MusicService();

  bool get isMusicOn => _isMusicOn;
  bool get isParentalControlOn => _isParentalControlOn; // ✅ Getter

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music') ?? true;
    _isParentalControlOn = prefs.getBool('parentalControl') ?? false; // ✅ Load setting

    if (_isMusicOn) {
      _musicService.playBackgroundMusic();
    }

    notifyListeners();
  }

  Future<void> toggleMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music', value);
    _isMusicOn = value;

    if (_isMusicOn) {
      _musicService.playBackgroundMusic();
    } else {
      _musicService.stopMusic();
    }

    notifyListeners();
  }

  // ✅ New method: Toggle Parental Control
  Future<void> toggleParentalControl(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('parentalControl', value);
    _isParentalControlOn = value;
    notifyListeners();
  }

  void pauseMusic() => _musicService.pauseMusic();

  void resumeMusic() {
    if (_isMusicOn) _musicService.playBackgroundMusic();
  }

  void stopMusic() => _musicService.stopMusic();
}
