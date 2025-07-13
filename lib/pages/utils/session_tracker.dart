// utils/session_tracker.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionTracker {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String profileName;
  final String userId;
  final String profileId;

  DateTime? _startTime;

  SessionTracker({
    required this.profileName,
    required this.userId,
    required this.profileId,
  });

  void startSession() {
    _startTime = DateTime.now();
  }

  Future<void> endSession() async {
    if (_startTime == null) return;

    DateTime endTime = DateTime.now();
    Duration duration = endTime.difference(_startTime!);

    await _firestore.collection('activity_logs').add({
      'profileName': profileName,
      'profileId': profileId, // 🔐 Log this too
      'userId': userId,
      'startTime': _startTime,
      'endTime': endTime,
      'durationInSeconds': duration.inSeconds,
      'activity': 'Session completed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
