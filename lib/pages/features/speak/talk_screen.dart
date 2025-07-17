import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../widgets/settings_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/session_tracker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TalkScreen extends StatefulWidget {
  final String profileName;
  final String profileId;
  final String userId;

  TalkScreen({
    required this.profileName,
    required this.profileId,
    required this.userId,
  });

  @override
  _TalkScreenState createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _recognizedText = 'Tap the mic and start speaking...';
  double _soundWaveAmplitude = 0.0;
  late SessionTracker _tracker;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _recordedPath;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _tracker = SessionTracker(
      profileName: widget.profileName,
      profileId: widget.profileId,
      userId: widget.userId,
    );
    _tracker.start();

    Future.delayed(Duration(milliseconds: 500), () {
      const greeting = "Hello! I'm your fox friend. Try saying something or say a word for me to check!";
      setState(() => _recognizedText = greeting);
      _tts.speak(greeting);
    });
  }

  @override
  void dispose() {
    _tracker.end();
    _speech.stop();
    _tts.stop();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    var micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      print("Microphone permission denied");
      return;
    }

    Directory tempDir = await getTemporaryDirectory();
    _recordedPath = '${tempDir.path}/pronunciation.wav';

    await _recorder.openRecorder();
    await _recorder.startRecorder(
      toFile: _recordedPath,
      codec: Codec.pcm16WAV,
    );
    print("Recording started at: $_recordedPath");
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    print("Recording stopped");
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );

    print("Speech available: $available");

    if (available) {
      await _startRecording();

      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) async {
          print('Speech result: ${val.recognizedWords}');

          setState(() {
            _recognizedText = val.recognizedWords;
            _soundWaveAmplitude = Random().nextDouble() * 30;
          });

          if (val.finalResult) {
            await _stopRecording();
            setState(() => _isListening = false);

            final regex = RegExp(r'say\s+(\w+)', caseSensitive: false);
            final match = regex.firstMatch(val.recognizedWords);
            if (match != null && match.groupCount > 0) {
              String expectedWord = match.group(1)!.toLowerCase();
              await _sendPronunciationFeedback(expectedWord);
            } else {
              await _sendToAI(val.recognizedWords);
            }
          }
        },
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

  Future<void> _sendToAI(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://digikids-ai.onrender.com/predict_intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final intent = result['intent'];
        final answer = result['answer'];
        print("Intent: $intent, Answer: $answer");
        await _respondToAnswer(answer);
      } else {
        print('Error from server: ${response.body}');
      }
    } catch (e) {
      print('Failed to send to AI: $e');
    }
  }

  Future<void> _sendPronunciationFeedback(String expectedWord) async {
    if (_recordedPath == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://digikids-ai.onrender.com/api/pronunciation-feedback'),
    );
    request.fields['expected'] = expectedWord;
    request.files.add(await http.MultipartFile.fromPath('audio', _recordedPath!));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feedback = data['feedback'];
      final prediction = data['prediction'];
      final confidence = data['confidence'];
      final spoken = data['spoken_word'];

      String emoji = {
        'correct': '🌟',
        'almost': '👍',
        'incorrect': '🔄',
      }[prediction] ?? '❓';

      setState(() {
        _recognizedText = "$emoji $feedback\nWord: $spoken\nConfidence: ${confidence.toStringAsFixed(2)}";
      });

      await _tts.speak(feedback);
    } else {
      print("Pronunciation error: ${response.body}");
    }
  }

  Future<void> _respondToAnswer(String answer) async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _recognizedText = answer;
    });
    await _tts.speak(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/background.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: SettingsButton(),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 300,
                    child: (kIsWeb || Platform.isAndroid || Platform.isIOS)
                        ? ModelViewer(
                            src: 'assets/models/fox.glb',
                            alt: "3D model of a fox",
                            ar: false,
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                            cameraOrbit: "0deg 75deg 2.5m",
                            fieldOfView: "35deg",
                          )
                        : Text(
                            "3D model viewer not supported.",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(height: 24),
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
                  CustomPaint(
                    size: const Size(double.infinity, 80),
                    painter: SoundWavePainter(_isListening, _soundWaveAmplitude),
                  ),
                ],
              ),
            ),
          ),
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
