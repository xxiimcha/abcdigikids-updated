// Filename: shapes_matching_game.dart

import 'package:flutter/material.dart';
import 'matching_game.dart';

class ShapesMatchingGame extends StatefulWidget {
  @override
  _ShapesMatchingGameState createState() => _ShapesMatchingGameState();
}

class _ShapesMatchingGameState extends State<ShapesMatchingGame> {
  final List<String> originalImages = [
    'assets/originals/circle.png',
    'assets/originals/square.png',
    'assets/originals/triangle.png',
  ];

  final List<String> shadowImages = [
    'assets/shadows/circle_shadow.png',
    'assets/shadows/square_shadow.png',
    'assets/shadows/triangle_shadow.png',
  ];

  List<bool> isMatched = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shapes Matching Game'),
        backgroundColor: Colors.teal,
      ),
      body: MatchingGameBody(
        originalImages: originalImages,
        shadowImages: shadowImages,
        isMatched: isMatched,
        categoryName: 'Shapes',
      ),
    );
  }
}
