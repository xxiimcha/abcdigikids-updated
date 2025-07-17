import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PinSetupPage extends StatefulWidget {
  final String userId;
  final String profileId;

  const PinSetupPage({required this.userId, required this.profileId, Key? key}) : super(key: key);

  @override
  _PinSetupPageState createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('app_profiles')
          .doc(widget.profileId)
          .update({'pin': _pinController.text.trim()});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN updated successfully'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update PIN: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade200, Colors.blueAccent.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Set or Change PIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Main content
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, size: 60, color: Colors.teal),
                              SizedBox(height: 16),
                              Text(
                                'Enter a 4-digit PIN to protect this profile',
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                obscureText: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(letterSpacing: 8, fontSize: 22),
                                decoration: InputDecoration(
                                  hintText: '●●●●',
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
                                    return 'Enter exactly 4 digits';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _isSaving ? null : _savePin,
                                icon: Icon(Icons.check),
                                label: _isSaving
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text('Save PIN'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
