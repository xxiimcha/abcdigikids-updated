import 'package:flutter/material.dart';
import 'dart:math';

class LettersMatchingGame extends StatefulWidget {
  @override
  _LettersMatchingGameState createState() => _LettersMatchingGameState();
}

class _LettersMatchingGameState extends State<LettersMatchingGame> {
  final List<String> originalImages = [
    'assets/letters/scoop_a.png',
    'assets/letters/scoop_b.png',
    'assets/letters/scoop_c.png',
  ];

  final List<String> targetImages = [
    'assets/letters/cone_a.png',
    'assets/letters/cone_b.png',
    'assets/letters/cone_c.png',
  ];

  List<bool> isMatched = [false, false, false];
  List<int> scoopPositions = [];
  List<int> conePositions = [];

  @override
  void initState() {
    super.initState();
    _randomizePositions();
  }

  void _randomizePositions() {
    // Generate random positions for scoops and cones
    scoopPositions = List<int>.generate(originalImages.length, (index) => index)..shuffle();
    conePositions = List<int>.generate(targetImages.length, (index) => index)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ice Cream Matching Game'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/balloons.gif', // Update with your child-friendly background
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Draggable scoops placed randomly
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(scoopPositions.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: _buildDraggable(scoopPositions[index]),
                    );
                  }),
                ),
                // Divider
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: 2,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    border: Border.all(color: Colors.teal),
                  ),
                ),
                // Drop cones placed randomly
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(conePositions.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: _buildDragTarget(conePositions[index]),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggable(int index) {
    return Draggable<String>(
      data: originalImages[index],
      feedback: _buildDraggableItem(index),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildDraggableItem(index),
      ),
      child: isMatched[index]
          ? Container() // Hide the draggable image when matched
          : _buildDraggableItem(index),
    );
  }

  Widget _buildDraggableItem(int index) {
    return Container(
      width: 100,
      height: 100,
      child: Image.asset(
        originalImages[index],
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildDragTarget(int index) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Cone image
            Image.asset(
              targetImages[index],
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            if (isMatched[index])
              // Scoop image positioned directly on top of the cone
              Positioned(
                bottom: 50, // Adjust this value so the scoop perfectly aligns with the cone
                child: Image.asset(
                  originalImages[index],
                  width: 100,
                  height: 100, // Adjust the height to maintain proportions
                  fit: BoxFit.contain,
                ),
              ),
          ],
        );
      },
      onWillAccept: (data) => data == originalImages[index],
      onAccept: (data) {
        setState(() {
          isMatched[index] = true;
        });
        _showSnackBar(context, '🎉 Matched Correctly! Great Job!');
        _checkIfAllMatched(); // Check if all items are matched
      },
      onLeave: (data) {
        _showSnackBar(context, '😅 Try Again!');
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _checkIfAllMatched() {
    if (isMatched.every((element) => element)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text('🎉 All Matched!'),
          content: Text('Do you want to play again or exit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _resetGame();
              },
              child: Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pop(context); // Navigate back to the PlayScreen
              },
              child: Text('Exit'),
            ),
          ],
        ),
      );
    }
  }

  void _resetGame() {
    setState(() {
      isMatched = [false, false, false];
      _randomizePositions(); // Randomize positions when game resets
    });
  }
}
