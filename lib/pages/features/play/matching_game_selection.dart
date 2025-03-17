import 'package:flutter/material.dart';
import 'matchingGame/letters_matching_game.dart'; // Import the LettersMatchingGame screen
import 'matching_game.dart'; // Import the generic MatchingGame screen for other categories

class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Category'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CategoryCard(
              title: 'Shapes',
              icon: Icons.category,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchingGame(category: 'Shapes'),
                  ),
                );
              },
            ),
            CategoryCard(
              title: 'Letters',
              icon: Icons.text_fields,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LettersMatchingGame(), // Navigate to LettersMatchingGame
                  ),
                );
              },
            ),
            CategoryCard(
              title: 'Animals',
              icon: Icons.pets,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchingGame(category: 'Animals'),
                  ),
                );
              },
            ),
            CategoryCard(
              title: 'Others',
              icon: Icons.extension,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchingGame(category: 'Others'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Category Card Widget
class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  CategoryCard({
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
        margin: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.white),
          title: Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
