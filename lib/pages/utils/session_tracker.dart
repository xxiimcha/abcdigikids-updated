// lib/utils/session_tracker.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionTracker {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String profileId;
  final String profileName;

  DateTime? _start;

  SessionTracker({
    required this.userId,
    required this.profileId,
    required this.profileName,
  });

  void start() {
    _start = DateTime.now();
  }

  Future<void> end() async {
    if (_start == null) return;
    final end = DateTime.now();
    final duration = end.difference(_start!);

    await _firestore.collection('activity_logs').add({
      'userId': userId,
      'profileId': profileId,
      'profileName': profileName,
      'startTime': _start,
      'endTime': end,
      'durationInSeconds': duration.inSeconds,
      'activity': 'Used TalkScreen',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
