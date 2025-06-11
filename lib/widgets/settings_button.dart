import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/utils/settings.dart';
import '../pages/settings/parental_control_settings.dart';

class SettingsButton extends StatelessWidget {
  final bool isLoggedIn;

  const SettingsButton({this.isLoggedIn = false, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : null,
            title: Text(
              "Settings",
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  // Background Music Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Background Music", style: TextStyle(color: isDark ? Colors.white70 : null)),
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

                  const SizedBox(height: 20),

                  // Volume Slider
                  Consumer<SettingsProvider>(
                    builder: (context, provider, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Volume", style: TextStyle(color: isDark ? Colors.white70 : null)),
                        Slider(
                          value: provider.volume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: (provider.volume * 100).round().toString(),
                          onChanged: (value) => provider.setVolume(value),
                          activeColor: Colors.teal,
                          inactiveColor: isDark ? Colors.white24 : Colors.grey[300],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.lock, color: Colors.teal.shade300),
                      title: Text("Parental Controls", style: TextStyle(color: isDark ? Colors.white : null)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : null),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ParentalControlSettingsPage()),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
