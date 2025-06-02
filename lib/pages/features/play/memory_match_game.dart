import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../../../widgets/settings_button.dart'; // ✅ Import settings button

class MemoryMatchGame extends StatefulWidget {
  @override
  _MemoryMatchGameState createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  final List<String> _cardContents = [
    '🍎', '🍎', '🍌', '🍌', '🍇', '🍇',
    '🍓', '🍓', '🍒', '🍒', '🥝', '🥝'
  ];

  late List<bool> _flipped;
  late List<bool> _matched;
  int _firstSelectedIndex = -1;
  int _secondSelectedIndex = -1;
  int _matchesFound = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _shuffleCards();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
  }

  void _shuffleCards() {
    setState(() {
      _cardContents.shuffle();
      _flipped = List<bool>.filled(_cardContents.length, false);
      _matched = List<bool>.filled(_cardContents.length, false);
      _matchesFound = 0;
      _firstSelectedIndex = -1;
      _secondSelectedIndex = -1;
    });
  }

  void _resetSelectedCards() {
    setState(() {
      _firstSelectedIndex = -1;
      _secondSelectedIndex = -1;
    });
  }

  void _flipCard(int index) {
    if (_flipped[index] || _matched[index] || _secondSelectedIndex != -1) return;

    setState(() {
      _flipped[index] = true;

      if (_firstSelectedIndex == -1) {
        _firstSelectedIndex = index;
      } else {
        _secondSelectedIndex = index;

        if (_cardContents[_firstSelectedIndex] == _cardContents[_secondSelectedIndex]) {
          _matched[_firstSelectedIndex] = true;
          _matched[_secondSelectedIndex] = true;
          _matchesFound++;

          if (_matchesFound == _cardContents.length ~/ 2) {
            _confettiController.play();
          }

          _resetSelectedCards();
        } else {
          Future.delayed(Duration(milliseconds: 800), () {
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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Match Game'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _shuffleCards,
          ),
          SettingsButton(), // ✅ Add Settings button here
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Matches Found: $_matchesFound / ${_cardContents.length ~/ 2}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _cardContents.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _flipCard(index),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _flipped[index] || _matched[index]
                                  ? [Colors.white, Colors.white]
                                  : [Colors.teal.shade400, Colors.teal.shade700],
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: _flipped[index] || _matched[index]
                                  ? Text(
                                      _cardContents[index],
                                      key: ValueKey(_cardContents[index] + index.toString()),
                                      style: TextStyle(fontSize: 36, color: Colors.black),
                                    )
                                  : Icon(Icons.help_outline, color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _shuffleCards,
                  child: Text('Restart Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.02,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
