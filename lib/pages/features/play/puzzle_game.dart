import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

class PuzzleGame extends StatefulWidget {
  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<int> _tiles = List.generate(9, (index) => index);
  int _emptyTile = 8;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2)); // Initialize first
    _shuffleTiles(); // Then shuffle tiles
  }


  void _shuffleTiles() {
    _tiles.shuffle(Random());
    while (!_isSolvable() || _isSolved()) {
      _tiles.shuffle(Random());
    }
    setState(() {});
  }

  bool _isSolvable() {
    int inversions = 0;
    for (int i = 0; i < _tiles.length - 1; i++) {
      for (int j = i + 1; j < _tiles.length; j++) {
        if (_tiles[i] != 0 && _tiles[j] != 0 && _tiles[i] > _tiles[j]) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0;
  }

  bool _isSolved() {
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) {
        return false;
      }
    }
    return true;
  }

  void _moveTile(int index) {
    int emptyIndex = _tiles.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        _tiles[emptyIndex] = _tiles[index];
        _tiles[index] = 0;
      });
      if (_isSolved()) {
        _confettiController.play();
        _showWinDialog();
      }
    }
  }

  bool _isAdjacent(int index1, int index2) {
    return (index1 % 3 == index2 % 3 && (index1 - index2).abs() == 3) ||
        (index1 ~/ 3 == index2 ~/ 3 && (index1 - index2).abs() == 1);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('🎉 Congratulations!', textAlign: TextAlign.center),
        content: Text('You solved the puzzle!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _shuffleTiles();
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Puzzle Game'),
        backgroundColor: Colors.teal.withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _shuffleTiles,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade300, Colors.blueAccent.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Arrange the tiles in order!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // Puzzle Grid
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _tiles.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _moveTile(index),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _tiles[index] == 0
                                  ? Colors.transparent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: _tiles[index] == 0
                                  ? []
                                  : [
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
                                transitionBuilder:
                                    (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: _tiles[index] == 0
                                    ? SizedBox.shrink()
                                    : Text(
                                        _tiles[index].toString(),
                                        key: ValueKey(_tiles[index]),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _shuffleTiles,
                  child: Text('Restart Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Confetti celebration effect
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
