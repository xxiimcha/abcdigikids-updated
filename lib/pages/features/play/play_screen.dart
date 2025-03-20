import 'package:flutter/material.dart';
import '../../utils/routes.dart'; // Import your AppRoutes class for navigation

class PlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/chalkboard.gif',
              fit: BoxFit.cover,
              width: screenWidth,
              height: screenHeight,
            ),
          ),
          // Semi-transparent overlay for improved readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                // Memory Match Game Card
                GameCard(
                  title: 'Memory Match',
                  icon: Icons.memory,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.memoryMatch);
                  },
                ),
                // Puzzle Game Card
                GameCard(
                  title: 'Puzzle Game',
                  icon: Icons.extension,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.puzzleGame);
                  },
                ),
                // Quiz Game Card
                GameCard(
                  title: 'Quiz Game',
                  icon: Icons.quiz,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.quizGame);
                  },
                ),
                // Identifying Game Card
                GameCard(
                  title: 'Identifying Game',
                  icon: Icons.visibility,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.identifyingGame);
                  },
                ),
                // Matching Game Card
                //GameCard(
                 // title: 'Matching Game',
                  //icon: Icons.drag_indicator,
                  //color: Colors.teal,
                  //onTap: () {
                    //Navigator.pushNamed(context, AppRoutes.matchingGameSelection);
                  //},
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Game Card Widget
class GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.8), // Slight transparency for a more dynamic look
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
