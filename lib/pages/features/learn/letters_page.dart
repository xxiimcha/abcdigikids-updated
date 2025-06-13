import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../../../widgets/settings_button.dart';

class LettersPage extends StatefulWidget {
  @override
  _LettersPageState createState() => _LettersPageState();
}

class _LettersPageState extends State<LettersPage> {
  final List<String> imagePaths = List.generate(
    26,
    (index) => 'assets/learn_abc/${String.fromCharCode(65 + index)}.png',
  );

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.4); // Child-friendly pace
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _speakCurrentLetter();
  }

  void _nextCard() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      Future.delayed(Duration(milliseconds: 350), _speakCurrentLetter);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      Future.delayed(Duration(milliseconds: 350), _speakCurrentLetter);
    }
  }

  Future<void> _speakCurrentLetter() async {
    try {
      final assetPath = imagePaths[_currentIndex];

      // Load image from assets
      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer;
      final imageBytes = buffer.asUint8List();

      // Write to temporary file (required for MLKit OCR)
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/ocr_image.png';
      final imageFile = await File(filePath).writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFilePath(filePath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.text.trim();
      final letter = String.fromCharCode(65 + _currentIndex);

      // Assume the last line is the keyword (e.g., Dog)
      final lines = extractedText.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final word = lines.isNotEmpty ? lines.last : "";

      final phrase = word.isNotEmpty ? "$letter is for $word" : letter;

      await _flutterTts.stop();
      await _flutterTts.speak(phrase);
    } catch (e) {
      print('Error with OCR or TTS: $e');
      await _flutterTts.speak(String.fromCharCode(65 + _currentIndex));
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Top buttons
          Positioned(
            top: 30,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 30,
            right: 16,
            child: SettingsButton(),
          ),
          // Flashcard swiper
          Column(
            children: [
              SizedBox(height: 80),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                imagePaths[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _previousCard,
                      child: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _nextCard,
                      child: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speakCurrentLetter,
        child: Icon(Icons.volume_up, size: 30, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
