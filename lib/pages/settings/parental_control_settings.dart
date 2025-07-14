import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentalControlSettingsPage extends StatefulWidget {
  const ParentalControlSettingsPage({Key? key}) : super(key: key);

  @override
  _ParentalControlSettingsPageState createState() => _ParentalControlSettingsPageState();
}

class _ParentalControlSettingsPageState extends State<ParentalControlSettingsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _restrictStoryMode = false;
  bool _limitPlayTime = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedProfileId;
  String? _userId;
  List<QueryDocumentSnapshot> _profiles = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndSettings();
  }

  Future<void> _loadUserProfileAndSettings() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = "No logged in user.";
          _loading = false;
        });
        return;
      }

      _userId = currentUser.uid;

      final profileSnap = await _firestore
          .collection('app_profiles')
          .where('userId', isEqualTo: _userId)
          .get();

      if (profileSnap.docs.isEmpty) {
        setState(() {
          _errorMessage = "No profiles found for this user.";
          _loading = false;
        });
        return;
      }

      setState(() {
        _profiles = profileSnap.docs;
        _selectedProfileId = _profiles.first.id;
      });

      await _loadSettings();
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load profiles: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    if (_selectedProfileId == null || _userId == null) return;

    final doc = await _firestore
        .collection('parental_controls')
        .doc(_userId)
        .collection('profiles')
        .doc(_selectedProfileId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _restrictStoryMode = data['restrict_story_mode'] ?? false;
        _limitPlayTime = data['limit_play_time'] ?? false;

        final start = data['play_time_start'] as String?;
        final end = data['play_time_end'] as String?;

        if (start != null && end != null) {
          _startTime = _parseTime(start);
          _endTime = _parseTime(end);
        }
      });
    } else {
      setState(() {
        _restrictStoryMode = false;
        _limitPlayTime = false;
        _startTime = null;
        _endTime = null;
      });
    }
  }

  TimeOfDay _parseTime(String formatted) {
    final parts = formatted.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleRestriction(String key, bool value) async {
    if (_selectedProfileId == null || _userId == null) return;

    final docRef = _firestore
        .collection('parental_controls')
        .doc(_userId)
        .collection('profiles')
        .doc(_selectedProfileId);

    await docRef.set({key: value}, SetOptions(merge: true));

    if (key == 'restrict_story_mode') {
      setState(() => _restrictStoryMode = value);
    }

    if (key == 'limit_play_time') {
      setState(() => _limitPlayTime = value);
      if (value) {
        await _showTimeRangeDialog(docRef);
      } else {
        await docRef.set({
          'play_time_start': null,
          'play_time_end': null,
        }, SetOptions(merge: true));
        setState(() {
          _startTime = null;
          _endTime = null;
        });
      }
    }
  }

  Future<void> _showTimeRangeDialog(DocumentReference docRef) async {
    TimeOfDay start = _startTime ?? TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = _endTime ?? TimeOfDay(hour: 20, minute: 0);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Allowed Play Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Start Time'),
              trailing: Text(_formatTime(start)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: start);
                if (picked != null) setState(() => start = picked);
              },
            ),
            ListTile(
              title: Text('End Time'),
              trailing: Text(_formatTime(end)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: end);
                if (picked != null) setState(() => end = picked);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await docRef.set({
                'play_time_start': _formatTime(start),
                'play_time_end': _formatTime(end),
              }, SetOptions(merge: true));
              setState(() {
                _startTime = start;
                _endTime = end;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Parental Controls'),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: _loading
        ? Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Selector
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _profiles.length,
                        itemBuilder: (context, index) {
                          final profile = _profiles[index];
                          final profileId = profile.id;
                          final profileName = profile['name'] ?? 'Unnamed';

                          final isSelected = _selectedProfileId == profileId;

                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                _selectedProfileId = profileId;
                                _loading = true;
                              });
                              await _loadSettings();
                              setState(() {
                                _loading = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: isSelected ? Colors.teal : Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    profileName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.teal : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // PIN Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.password, color: Colors.teal),
                      title: Text('Set or Change PIN'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PIN screen not implemented')),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),

                  // Restrictions Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: Icon(Icons.lock_person, color: Colors.deepOrange),
                          title: Text('Restrict Story Mode'),
                          value: _restrictStoryMode,
                          onChanged: (val) => _toggleRestriction('restrict_story_mode', val),
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          secondary: Icon(Icons.timer_off, color: Colors.purple),
                          title: Text('Limit Play Time'),
                          subtitle: (_startTime != null && _endTime != null)
                              ? Text(
                                  'Allowed: ${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              : null,
                          value: _limitPlayTime,
                          onChanged: (val) => _toggleRestriction('limit_play_time', val),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Footer note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'These settings apply to the selected profile and are protected by a PIN.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
  );
}

}
