class UsageDashboardPage extends StatelessWidget {
  final String userId;
  final String profileId;

  const UsageDashboardPage({required this.userId, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('usage_logs')
            .doc(userId)
            .collection('profiles')
            .doc(profileId)
            .collection('logs')
            .orderBy('timestamp', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No usage logs found.'));

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              final dt = (log['timestamp'] as Timestamp).toDate();
              return ListTile(
                leading: Icon(Icons.history),
                title: Text(log['screen'] ?? 'Unknown'),
                subtitle: Text('${dt.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}
