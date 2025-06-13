import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as path;
import '../../../widgets/settings_button.dart';

class ShapesPage extends StatefulWidget {
  @override
  _ShapesPageState createState() => _ShapesPageState();
}

class _ShapesPageState extends State<ShapesPage> {
  final List<String> imagePaths = List.generate(
    8,
    (index) => 'assets/learn_shapes/${[
      'circle',
      'diamond',
      'heart',
      'oval',
      'rectangle',
      'square',
      'star',
      'triangle'
    ][index]}.png',
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
    _speakCurrentShape();
  }

  void _nextCard() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentShape);
    } else {
      _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentShape);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentShape);
    } else {
      _pageController.animateToPage(imagePaths.length - 1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      Future.delayed(Duration(milliseconds: 350), _speakCurrentShape);
    }
  }

  String _getShapeName(String filePath) {
    return path.basenameWithoutExtension(filePath); // e.g., 'circle'
  }

  Future<void> _speakCurrentShape() async {
    final shapeName = _getShapeName(imagePaths[_currentIndex]);
    await _flutterTts.stop();
    await _flutterTts.speak(shapeName);
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

          // Top controls
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
                    final shapeName = _getShapeName(imagePaths[index]);
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                imagePaths[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _previousCard,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                        shape: StadiumBorder(),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _speakCurrentShape,
                      child: Icon(Icons.volume_up, size: 30, color: Colors.white),
                      backgroundColor: Colors.deepPurple,
                      elevation: 6,
                    ),
                    ElevatedButton.icon(
                      onPressed: _nextCard,
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                        shape: StadiumBorder(),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
