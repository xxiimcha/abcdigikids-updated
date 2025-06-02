import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../widgets/settings_button.dart'; // ✅ Add this import

class ColorsPage extends StatefulWidget {
  @override
  _ColorsPageState createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
  final FlutterTts _flutterTts = FlutterTts();

  final List<String> imagePaths = [
    'assets/learn_colors/red.png',
    'assets/learn_colors/blue.png',
    'assets/learn_colors/green.png',
    'assets/learn_colors/yellow.png',
  ];

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  String _getColorName(String imagePath) {
    return imagePath.split('/').last.split('.').first;
  }

  Future<void> _speakColorName() async {
    String colorName = _getColorName(imagePaths[_currentIndex]);
    await _flutterTts.speak(colorName);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _speakColorName();
  }

  void _nextCard() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _pageController.animateToPage(imagePaths.length - 1, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/background.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Back and Settings buttons
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

          // Main Content
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
                            _getColorName(imagePaths[index]).toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        onPressed: _speakColorName,
        child: Icon(Icons.mic, size: 30, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
