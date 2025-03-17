import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../utils/bottom_navbar.dart'; // Adjust the import path for your BottomNavBar widget

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
  int _bottomNavIndex = 1; // Separate index for BottomNavigationBar

  // Function to extract the color name from the image path
  String _getColorName(String imagePath) {
    return imagePath.split('/').last.split('.').first; // Extracts "red" from "red.png"
  }

  // Function to read the color name aloud
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

  // Handle page change for looping effect
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _speakColorName();
  }

  // Navigate to the next flashcard with smooth looping
  void _nextCard() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      // Smooth transition to first page
      _pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  // Navigate to the previous flashcard with smooth looping
  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      // Smooth transition to last page
      _pageController.animateToPage(imagePaths.length - 1, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    }
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
          Column(
            children: [
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
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _bottomNavIndex, // Separate index for BottomNavigationBar
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });

          if (index == 0) {
            Navigator.pushNamed(context, '/play');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/learn');
          }
        },
      ),
    );
  }
}
