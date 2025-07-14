import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsageDashboardPage extends StatelessWidget {
  final String userId;
  final String profileId;

  const UsageDashboardPage({
    Key? key,
    required this.userId,
    required this.profileId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usageRef = FirebaseFirestore.instance
        .collection('usage_logs')
        .doc(userId)
        .collection('profiles')
        .doc(profileId)
        .collection('logs');

    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: usageRef.orderBy('timestamp', descending: true).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No usage logs found.'));
          }

          final logs = snapshot.data!.docs;

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => Divider(height: 20),
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              final screen = data['screen'] ?? 'Unknown';
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                leading: Icon(Icons.history, color: Colors.indigo),
                title: Text(screen, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${timestamp.toLocal()}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
