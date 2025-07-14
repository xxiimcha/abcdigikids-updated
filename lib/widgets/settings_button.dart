// Redesigned SettingsButton with YouTube Kids–inspired parental check and animated dialog
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../pages/utils/settings.dart';
import '../pages/settings/parental_control_settings.dart';

class SettingsButton extends StatelessWidget {
  final bool isLoggedIn;

  const SettingsButton({this.isLoggedIn = false, super.key});

  Future<bool> verifyMathDialog(BuildContext context) async {
    bool isVerified = false;
    final rand = Random();
    final a = rand.nextInt(9) + 1;
    final b = rand.nextInt(9) + 1;
    final correctAnswer = a * b;
    String userAnswer = '';

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Parental Verification',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Icon(Icons.verified_user, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Parents only',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'To continue, please enter the correct answer',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$a x $b = ?',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          hintText: '# #',
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => userAnswer = value,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (int.tryParse(userAnswer) == correctAnswer) {
                              isVerified = true;
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Incorrect answer. Try again.")),
                              );
                            }
                          },
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return isVerified;
  }

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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.settings, color: Colors.red),
                SizedBox(width: 8),
                Text("Settings", style: TextStyle(color: Colors.black)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Background Music"),
                      Consumer<SettingsProvider>(
                        builder: (context, provider, _) => Switch(
                          value: provider.isMusicOn,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            provider.toggleMusic(value);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer<SettingsProvider>(
                    builder: (context, provider, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Volume"),
                        Slider(
                          value: provider.volume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: (provider.volume * 100).round().toString(),
                          onChanged: (value) => provider.setVolume(value),
                          activeColor: Colors.red,
                          inactiveColor: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.red.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: const Icon(Icons.lock, color: Colors.red),
                    title: const Text("Parental Controls"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                    onTap: () async {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        final verified = await verifyMathDialog(context);
                        if (verified) {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ParentalControlSettingsPage(),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in")),
                        );
                      }
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
