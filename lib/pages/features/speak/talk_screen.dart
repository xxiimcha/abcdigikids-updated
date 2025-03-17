import 'package:flutter/material.dart';
import '../../utils/bottom_navbar.dart'; // Import your BottomNavBar widget
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  int _selectedIndex = 1;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = 'Tap the mic and start speaking...';
  double _soundWaveAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Handle navigation based on tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        Navigator.pop(context); // Pop the current screen
      }
    });
  }

  // Start listening to user's speech
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _recognizedText = val.recognizedWords;
          _soundWaveAmplitude = Random().nextDouble() * 30; // Simulate amplitude changes
        }),
      );
    }
  }

  // Stop listening to user's speech
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _soundWaveAmplitude = 0.0; // Reset soundwave
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/background.gif', // Ensure this path matches your asset structure
                fit: BoxFit.cover,
              ),
            ),

            // Semi-transparent overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
              ),
            ),

            // Centered content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    // Display recognized speech
                    Text(
                      _recognizedText,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20), // Space between text and soundwave

                    // Soundwave visual
                    CustomPaint(
                      size: Size(double.infinity, 100),
                      painter: SoundWavePainter(_isListening, _soundWaveAmplitude),
                    ),

                    SizedBox(height: 40), // Space between soundwave and microphone button

                    // Microphone button with gradient background
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.yellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            size: 60,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action for microphone
          if (_isListening) {
            _stopListening();
          } else {
            _startListening();
          }
        },
        child: Icon(Icons.mic, size: 30, color: Colors.white), // Microphone icon for Talk
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Painter for the soundwave effect
class SoundWavePainter extends CustomPainter {
  final bool isListening;
  final double amplitude;

  SoundWavePainter(this.isListening, this.amplitude);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw the soundwave
    final path = Path();
    double waveHeight = amplitude;
    double frequency = 0.02;

    for (double x = 0; x <= size.width; x++) {
      double y = size.height / 2 + sin(x * frequency) * waveHeight;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (isListening) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
