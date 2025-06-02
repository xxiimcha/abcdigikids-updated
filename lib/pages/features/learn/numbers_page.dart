import 'package:flutter/material.dart';
import '../../../widgets/settings_button.dart'; // ✅ Import settings button widget

class NumbersPage extends StatefulWidget {
  @override
  _NumbersPageState createState() => _NumbersPageState();
}

class _NumbersPageState extends State<NumbersPage> {
  final List<String> imagePaths = [
    'assets/learn_numbers/1.png',
    'assets/learn_numbers/2.png',
    'assets/learn_numbers/3.png',
    'assets/learn_numbers/4.png',
    // Add more image paths if needed
  ];

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextCard() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _pageController.animateToPage(imagePaths.length - 1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
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

          // Main content
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
        onPressed: () {
          // TODO: Add speech or sound logic here
        },
        child: Icon(Icons.mic, size: 30, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
