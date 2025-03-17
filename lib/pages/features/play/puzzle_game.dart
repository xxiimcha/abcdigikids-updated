import 'package:flutter/material.dart';
import 'dart:math';

class PuzzleGame extends StatefulWidget {
  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<int> _tiles = List.generate(9, (index) => index); // Numbers 0-8
  int _emptyTile = 8;

  @override
  void initState() {
    super.initState();
    _shuffleTiles();
  }

  // Shuffle the tiles at the start of the game
  void _shuffleTiles() {
    _tiles.shuffle(Random());
    while (!_isSolvable() || _isSolved()) {
      _tiles.shuffle(Random());
    }
    setState(() {});
  }

  // Check if the puzzle is solvable
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

  // Check if the puzzle is already solved
  bool _isSolved() {
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) {
        return false;
      }
    }
    return true;
  }

  // Move a tile if it is adjacent to the empty space
  void _moveTile(int index) {
    int emptyIndex = _tiles.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        _tiles[emptyIndex] = _tiles[index];
        _tiles[index] = 0;
      });
      if (_isSolved()) {
        _showWinDialog();
      }
    }
  }

  // Check if two indices are adjacent
  bool _isAdjacent(int index1, int index2) {
    if ((index1 % 3 == index2 % 3 && (index1 - index2).abs() == 3) ||
        (index1 ~/ 3 == index2 ~/ 3 && (index1 - index2).abs() == 1)) {
      return true;
    }
    return false;
  }

  // Show a dialog when the player wins
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('🎉 Congratulations!'),
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
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Game'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: _tiles.length,
          itemBuilder: (context, index) {
            if (_tiles[index] == 0) {
              return Container(
                color: Colors.transparent,
              ); // Empty space
            } else {
              return GestureDetector(
                onTap: () => _moveTile(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
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
                      _tiles[index].toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
