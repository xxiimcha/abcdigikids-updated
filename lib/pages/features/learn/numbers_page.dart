import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../widgets/settings_button.dart';

class NumbersPage extends StatefulWidget {
  @override
  _NumbersPageState createState() => _NumbersPageState();
}

class _NumbersPageState extends State<NumbersPage> {
  final List<String> imagePaths = List.generate(
    10, // Change to the number of flashcards you have
    (index) => 'assets/learn_numbers/${index + 1}.png',
  );
  
  final PageController _pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.4);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _speakCurrentCard();
  }

  void _nextCard() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentCard);
    } else {
      _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentCard);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentCard);
    } else {
      _pageController.animateToPage(imagePaths.length - 1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentCard);
    }
  }

  Future<void> _speakCurrentCard() async {
    try {
      final assetPath = imagePaths[_currentIndex];
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/temp_number_image.png';
      final imageFile = await File(filePath).writeAsBytes(bytes);

      final inputImage = InputImage.fromFilePath(filePath);
      final recognizer = TextRecognizer();
      final result = await recognizer.processImage(inputImage);

      final lines = result.text.trim().split('\n').where((e) => e.trim().isNotEmpty).toList();
      final content = lines.isNotEmpty ? lines.last : "a number";

      await _flutterTts.stop();
      await _flutterTts.speak("This is $content.");
    } catch (e) {
      print("OCR or TTS error: $e");
      await _flutterTts.speak("This is number ${_currentIndex + 1}.");
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
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/background.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
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
                      padding: const EdgeInsets.all(16.0),
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
                          Text(
                            'Number ${index + 1}',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
        onPressed: _speakCurrentCard,
        child: Icon(Icons.volume_up, size: 30, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
