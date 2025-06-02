import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/utils/settings.dart'; // ✅ Import your existing SettingsProvider

class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings, color: Colors.white),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Settings"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Background Music"),
                Consumer<SettingsProvider>(
                  builder: (context, provider, _) => Switch(
                    value: provider.isMusicOn,
                    onChanged: (value) {
                      provider.toggleMusic(value);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
