import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/utils/settings.dart'; // ✅ SettingsProvider
import '../pages/settings/parental_control_settings.dart'; // Create this page

class SettingsButton extends StatelessWidget {
  final bool isLoggedIn;

  SettingsButton({this.isLoggedIn = false}); // Pass true only when user is authenticated

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings, color: Colors.white),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Settings"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Background Music Toggle
                Row(
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

                SizedBox(height: 16),

                // Parental Controls Navigation (only if logged in)
                if (isLoggedIn)
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.teal),
                    title: Text("Parental Controls"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ParentalControlSettingsPage(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
