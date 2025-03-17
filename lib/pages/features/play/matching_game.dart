import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MatchingGame extends StatefulWidget {
  final String category;

  MatchingGame({required this.category});

  @override
  _MatchingGameState createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  late List<String> originalImages;
  late List<String> shadowImages;
  List<bool> isMatched = [];
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadCategoryData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Load images and shadow images based on the selected category
  void _loadCategoryData() {
    if (widget.category == 'Shapes') {
      originalImages = [
        'assets/originals/circle.png',
        'assets/originals/square.png',
        'assets/originals/triangle.png',
      ];
      shadowImages = [
        'assets/shadows/circle_shadow.png',
        'assets/shadows/square_shadow.png',
        'assets/shadows/triangle_shadow.png',
      ];
    } else if (widget.category == 'Letters') {
      originalImages = [
        'assets/originals/a.png',
        'assets/originals/b.png',
        'assets/originals/c.png',
      ];
      shadowImages = [
        'assets/shadows/a_shadow.png',
        'assets/shadows/b_shadow.png',
        'assets/shadows/c_shadow.png',
      ];
    } else if (widget.category == 'Animals') {
      originalImages = [
        'assets/originals/cat.png',
        'assets/originals/dog.png',
        'assets/originals/bird.png',
      ];
      shadowImages = [
        'assets/shadows/cat_shadow.png',
        'assets/shadows/dog_shadow.png',
        'assets/shadows/bird_shadow.png',
      ];
    } else if (widget.category == 'Others') {
      originalImages = [
        'assets/originals/pig.png',
        'assets/originals/fish.png',
        'assets/originals/crocodile.png',
      ];
      shadowImages = [
        'assets/shadows/pig_shadow.png',
        'assets/shadows/fish_shadow.png',
        'assets/shadows/crocodile_shadow.png',
      ];
    }
    isMatched = List<bool>.filled(originalImages.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Game - ${widget.category}'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/balloons.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(originalImages.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: _buildDraggable(index),
                    );
                  }),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: 2,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    border: Border.all(color: Colors.teal),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(shadowImages.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: _buildDragTarget(index),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.pinkAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Image.asset(
        originalImages[index],
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildDragTarget(int index) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.teal,
              width: 2,
            ),
          ),
          child: isMatched[index]
              ? Image.asset(originalImages[index], fit: BoxFit.contain)
              : Image.asset(shadowImages[index], fit: BoxFit.contain),
        );
      },
      onWillAccept: (data) => data == originalImages[index],
      onAccept: (data) {
        setState(() {
          isMatched[index] = true;
        });
        _showSnackBar(context, '🎉 Matched Correctly! Great Job!');
        _checkIfAllMatched();
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
      _playSuccessAudio(); // Play audio when all matched
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

  Future<void> _playSuccessAudio() async {
    await _audioPlayer.play(AssetSource('music/yehey.mp3'));
  }

  void _resetGame() {
    setState(() {
      isMatched = List<bool>.filled(originalImages.length, false);
    });
  }
}
