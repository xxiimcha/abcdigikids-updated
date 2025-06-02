import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/music.service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isMusicOn = true;
  final MusicService _musicService = MusicService();

  bool get isMusicOn => _isMusicOn;

  SettingsProvider() {
    _loadMusicSetting();
  }

  Future<void> _loadMusicSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music') ?? true;
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

  void pauseMusic() => _musicService.pauseMusic();
  void resumeMusic() {
    if (_isMusicOn) _musicService.playBackgroundMusic();
  }

  void stopMusic() => _musicService.stopMusic();
}
