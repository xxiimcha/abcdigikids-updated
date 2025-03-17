import 'package:flutter/material.dart';

class MemoryMatchGame extends StatefulWidget {
  @override
  _MemoryMatchGameState createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  // Define the card data (you can replace these with images or other assets)
  final List<String> _cardContents = [
    '🍎', '🍎', '🍌', '🍌', '🍇', '🍇',
    '🍓', '🍓', '🍒', '🍒', '🥝', '🥝'
  ];

  late List<bool> _flipped;
  late List<bool> _matched;
  int _firstSelectedIndex = -1;
  int _secondSelectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _cardContents.shuffle(); // Shuffle the cards at the start
    _flipped = List<bool>.filled(_cardContents.length, false); // Initialize the flipped state
    _matched = List<bool>.filled(_cardContents.length, false); // Initialize the matched state
  }

  void _resetSelectedCards() {
    setState(() {
      _firstSelectedIndex = -1;
      _secondSelectedIndex = -1;
    });
  }

  void _flipCard(int index) {
    if (_flipped[index] || _matched[index] || _secondSelectedIndex != -1) {
      return; // Ignore if already matched or two cards are already selected
    }

    setState(() {
      _flipped[index] = true;
      if (_firstSelectedIndex == -1) {
        _firstSelectedIndex = index;
      } else {
        _secondSelectedIndex = index;
        // Check for a match
        if (_cardContents[_firstSelectedIndex] == _cardContents[_secondSelectedIndex]) {
          _matched[_firstSelectedIndex] = true;
          _matched[_secondSelectedIndex] = true;
          _resetSelectedCards();
        } else {
          // If not a match, flip back after a short delay
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _flipped[_firstSelectedIndex] = false;
              _flipped[_secondSelectedIndex] = false;
              _resetSelectedCards();
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Match Game'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _cardContents.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _flipCard(index);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _flipped[index] || _matched[index] ? Colors.white : Colors.teal,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _flipped[index] || _matched[index]
                        ? _cardContents[index]
                        : '',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
