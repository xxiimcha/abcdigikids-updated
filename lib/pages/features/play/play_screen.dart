import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/routes.dart';
import '../../../widgets/settings_button.dart';

class PlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // 🔥 Remove white bar
        systemNavigationBarColor: Colors.black, // optional: nav bar style
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false, // 🔥 Important: let background go to top
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
              // Settings Button
              Positioned(
                top: 40,
                right: 16,
                child: SettingsButton(),
              ),
              // Game Cards
              Padding(
                padding: const EdgeInsets.only(top: 120.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
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
      ),
    );
  }
}

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
        color: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
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
                fontFamily: 'ComicSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
