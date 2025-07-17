import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../utils/routes.dart';
import '../../../widgets/settings_button.dart';

class TalkScreen extends StatefulWidget {
  final String profileName;
  final String profileId;
  final String userId;

  const TalkScreen({
    super.key,
    required this.profileName,
    required this.profileId,
    required this.userId,
  });

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> with SingleTickerProviderStateMixin {
  final List<_Message> _messages = [];
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    Gemini.init(apiKey: 'AIzaSyBKOrnJJytrrY248l3kv6xUBULeID0jI0U');
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setLanguage("en-US");
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _isListening = false;
      });
    });

    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isSpeaking) return;

    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _micAnimationController.repeat(reverse: true);

      _speech.listen(
        listenMode: stt.ListenMode.confirmation,
        localeId: 'en_US',
        onResult: (val) async {
          print("Speech result: ${val.recognizedWords}");

          if (val.recognizedWords.isNotEmpty) {
            setState(() {
              _messages.add(_Message(role: 'You', content: val.recognizedWords));
              _isLoading = true;
            });

            await _speech.stop();
            await _askGemini(val.recognizedWords);
          }
        },
      );
    } else {
      print("Speech recognition unavailable.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Speech recognition unavailable.")));
    }
  }

  Future<void> _askGemini(String prompt) async {
    final childFriendlyPrompt = prompt;

    try {
      final result = await Gemini.instance.text(childFriendlyPrompt);
      final output = result?.output?.trim().isNotEmpty == true
          ? result!.output!
          : "No response from Gemini";

      print("Gemini response: $output");

      setState(() {
        _messages.add(_Message(role: 'Gemini', content: output));
        _isLoading = false;
        _isSpeaking = true;
        _isListening = false;
      });

      _micAnimationController.repeat(reverse: true);
      await _tts.speak(output);
    } catch (e) {
      print("Gemini error: $e");
      setState(() {
        _messages.add(_Message(role: 'Gemini', content: 'Error: ${e.toString()}'));
        _isLoading = false;
        _isSpeaking = false;
        _isListening = false;
      });
    } finally {
      _micAnimationController.stop();
    }
  }

  Widget _buildLyricScroll() {
    return Expanded(
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[_messages.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.role,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double micScale = _isListening || _isSpeaking
        ? _micAnimationController.value
        : 1.0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'profileName': widget.profileName,
            'profileId': widget.profileId,
            'userId': widget.userId,
          },
        );
        return false;
      },

      child: Scaffold(
        body: Stack(
          children: [
            // Background GIF
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/background.gif',
                fit: BoxFit.cover,
              ),
            ),

            // Overlay for readability
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            // Top settings button
            Positioned(
              top: 40,
              right: 16,
              child: SettingsButton(),
            ),

            // Foreground content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  if (_isSpeaking)
                    const Column(
                      children: [
                        Icon(Icons.volume_up, color: Colors.white, size: 40),
                        SizedBox(height: 6),
                        Text("Gemini is speaking...", style: TextStyle(color: Colors.white)),
                        SizedBox(height: 12),
                      ],
                    ),
                  if (_isListening)
                    const Column(
                      children: [
                        Icon(Icons.hearing, color: Colors.white, size: 40),
                        SizedBox(height: 6),
                        Text("Listening...", style: TextStyle(color: Colors.white)),
                        SizedBox(height: 12),
                      ],
                    ),
                  _buildLyricScroll(),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Mic button centered
            Center(
              child: GestureDetector(
                onTap: (!_isListening && !_isSpeaking) ? _startListening : null,
                child: Transform.scale(
                  scale: micScale,
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.pinkAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 6,
                        )
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 64),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _Message {
  final String role;
  final String content;

  _Message({required this.role, required this.content});
}
