// Filename: matching_game.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MatchingGameBody extends StatefulWidget {
  final List<String> originalImages;
  final List<String> shadowImages;
  final List<bool> isMatched;
  final String categoryName;

  MatchingGameBody({
    required this.originalImages,
    required this.shadowImages,
    required this.isMatched,
    required this.categoryName,
  });

  @override
  _MatchingGameBodyState createState() => _MatchingGameBodyState();
}

class _MatchingGameBodyState extends State<MatchingGameBody> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/backgrounds/balloons.gif', // Update with your child-friendly background
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
                children: List.generate(widget.originalImages.length, (index) {
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
                children: List.generate(widget.shadowImages.length, (index) {
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
    );
  }

  Widget _buildDraggable(int index) {
    return Draggable<String>(
      data: widget.originalImages[index],
      feedback: _buildDraggableItem(index),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildDraggableItem(index),
      ),
      child: widget.isMatched[index]
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
        widget.originalImages[index],
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
          child: widget.isMatched[index]
              ? Image.asset(widget.originalImages[index], fit: BoxFit.contain)
              : Image.asset(widget.shadowImages[index], fit: BoxFit.contain),
        );
      },
      onWillAccept: (data) => data == widget.originalImages[index],
      onAccept: (data) {
        setState(() {
          widget.isMatched[index] = true;
        });
        _checkIfAllMatched();
      },
    );
  }

  void _checkIfAllMatched() {
    if (widget.isMatched.every((element) => element)) {
      _playSuccessAudio();
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
    await _audioPlayer.play(AssetSource('sounds/yehey.mp3'));
  }

  void _resetGame() {
    setState(() {
      widget.isMatched.fillRange(0, widget.isMatched.length, false);
    });
  }
}
