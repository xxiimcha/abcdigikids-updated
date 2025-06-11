import 'package:flutter/material.dart';

class ParentalControlSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parental Controls'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section: PIN Management
          ListTile(
            leading: Icon(Icons.password, color: Colors.teal),
            title: Text('Set or Change PIN'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to PIN setup/change screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PIN screen not implemented')),
              );
            },
          ),

          Divider(),

          // Section: Feature Restrictions
          ListTile(
            leading: Icon(Icons.lock_person, color: Colors.deepOrange),
            title: Text('Restrict Story Mode'),
            trailing: Switch(
              value: false, // TODO: Load from state/provider
              onChanged: (val) {
                // TODO: Save setting (via Provider or SharedPreferences)
              },
            ),
          ),

          ListTile(
            leading: Icon(Icons.timer_off, color: Colors.purple),
            title: Text('Limit Play Time'),
            trailing: Switch(
              value: false, // TODO: Load from state/provider
              onChanged: (val) {
                // TODO: Save setting (via Provider or SharedPreferences)
              },
            ),
          ),

          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'These settings are protected by a PIN and help parents control app usage.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
