import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../widgets/settings_button.dart';

class TalkScreen extends StatefulWidget {
  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = 'Tap the mic and start speaking...';
  double _soundWaveAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

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
          _soundWaveAmplitude = Random().nextDouble() * 30;
        }),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _soundWaveAmplitude = 0.0;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.black, // fallback
    body: Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/backgrounds/background.gif',
            fit: BoxFit.cover,
          ),
        ),

        // Overlay
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),

        // Top-right settings button
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: SettingsButton(),
        ),

        // Main content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D model
                SizedBox(
                  height: 200,
                  width: 200,
                  child: (kIsWeb || Platform.isAndroid || Platform.isIOS)
                      ? ModelViewer(
                          src: 'assets/models/fox.glb',
                          alt: "3D model of a fox",
                          ar: false,
                          autoRotate: true,
                          cameraControls: true,
                          backgroundColor: Colors.transparent,
                        )
                      : Text(
                          "3D model viewer not supported.",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(height: 24),

                // Recognized text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _recognizedText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Soundwave
                CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: SoundWavePainter(_isListening, _soundWaveAmplitude),
                ),
              ],
            ),
          ),
        ),

        // Mic button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.yellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () {
                  _isListening ? _stopListening() : _startListening();
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
