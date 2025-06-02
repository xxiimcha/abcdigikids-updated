import 'package:flutter/material.dart';
import '../../utils/routes.dart';
import '../../../widgets/settings_button.dart'; // Add this import

class PlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/chalkboard.gif',
                fit: BoxFit.cover,
              ),
            ),
            // Semi-transparent overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Settings Button
            Positioned(
              top: 16,
              right: 16,
              child: SettingsButton(),
            ),
            // Game Cards
            Padding(
              padding: const EdgeInsets.only(top: 70.0, left: 16.0, right: 16.0, bottom: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  GameCard(
                    title: 'Memory Match',
                    icon: Icons.memory,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.memoryMatch);
                    },
                  ),
                  GameCard(
                    title: 'Puzzle Game',
                    icon: Icons.extension,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.puzzleGame);
                    },
                  ),
                  GameCard(
                    title: 'Quiz Game',
                    icon: Icons.quiz,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.quizGame);
                    },
                  ),
                  GameCard(
                    title: 'Identifying Game',
                    icon: Icons.visibility,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.identifyingGame);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
        color: color.withOpacity(0.8),
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
