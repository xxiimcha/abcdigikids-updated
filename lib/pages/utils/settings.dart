import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsUtil {
  static const String _musicKey = 'music';

  static Future<bool> isMusicOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicKey) ?? true;
  }

  static Future<void> setMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, value);
  }

  static Future<void> showSettingsDialog(BuildContext context, VoidCallback onToggle) async {
    bool current = await isMusicOn();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Settings"),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Background Music"),
              Switch(
                value: current,
                onChanged: (value) async {
                  await setMusic(value);
                  setState(() => current = value);
                  onToggle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
