import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/music.service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isMusicOn = true;
  bool _isParentalControlOn = false;
  double _volume = 0.5; // ✅ Default volume

  final MusicService _musicService = MusicService();

  bool get isMusicOn => _isMusicOn;
  bool get isParentalControlOn => _isParentalControlOn;
  double get volume => _volume;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music') ?? true;
    _isParentalControlOn = prefs.getBool('parentalControl') ?? false;
    _volume = prefs.getDouble('volume') ?? 0.5;

    _musicService.setVolume(_volume);

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

  Future<void> toggleParentalControl(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('parentalControl', value);
    _isParentalControlOn = value;
    notifyListeners();
  }

  // ✅ New method for volume control
  Future<void> setVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
    _volume = value;
    _musicService.setVolume(value);
    notifyListeners();
  }

  void pauseMusic() => _musicService.pauseMusic();

  void resumeMusic() {
    if (_isMusicOn) _musicService.playBackgroundMusic();
  }

  void stopMusic() => _musicService.stopMusic();
}
