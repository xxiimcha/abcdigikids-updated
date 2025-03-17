import 'package:flutter/material.dart';
import '../pages/features/learn/numbers_page.dart';
import '../pages/features/learn/colors_page.dart';
import '../pages/features/learn/letters_page.dart';
import '../pages/features/learn/shapes_page.dart';

class SwipePageView extends StatelessWidget {
  final int initialPageIndex; // To start at the selected category

  SwipePageView({required this.initialPageIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: PageController(initialPage: initialPageIndex), // Set initial page
        children: [
          NumbersPage(),  // Index 0
          ShapesPage(),   // Index 1
          LettersPage(),  // Index 2
          ColorsPage(),   // Index 3
        ],
      ),
    );
  }
}
