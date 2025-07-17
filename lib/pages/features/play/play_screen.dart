import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/routes.dart';
import '../../../widgets/settings_button.dart';

class PlayScreen extends StatefulWidget {
  final String? profileName;
  final String? profileId;
  final String? userId;

  const PlayScreen({
    super.key,
    required this.profileName,
    required this.profileId,
    required this.userId,
  });

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  Widget build(BuildContext context) {
    final String profileName = widget.profileName ?? 'Guest';
    final String profileId = widget.profileId ?? '';
    final String userId = widget.userId ?? '';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'profileName': profileName,
            'profileId': profileId,
            'userId': userId,
          },
        );
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/backgrounds/chalkboard.gif',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: SettingsButton(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 120.0, left: 16.0, right: 16.0, bottom: 16.0),
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
                          Navigator.pushNamed(
                              context, AppRoutes.identifyingGame);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  const GameCard({
    super.key,
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
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
