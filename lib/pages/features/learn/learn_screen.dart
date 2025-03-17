import 'package:flutter/material.dart';
import '../../../widgets/_pageswipe.dart';
import 'numbers_page.dart';
import 'shapes_page.dart';
import 'letters_page.dart';
import 'colors_page.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
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
                width: screenWidth,
                height: screenHeight,
              ),
            ),
            // Semi-transparent overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Section
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Expanded category list to fill remaining space
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Category Cards with new design
                            CategoryCard(
                              color: Colors.orangeAccent,
                              title: 'Colors',
                              subtitle: 'Learn the different colors.',
                              iconPath: 'assets/icons/colors_icon.png',
                            ),
                            CategoryCard(
                              color: Colors.lightBlueAccent,
                              title: 'Numbers',
                              subtitle: 'Learn to count with numbers!',
                              iconPath: 'assets/icons/numbers_icon.png',
                            ),
                            CategoryCard(
                              color: Colors.greenAccent,
                              title: 'Shapes',
                              subtitle: 'Discover different shapes!',
                              iconPath: 'assets/icons/shapes_icon.png',
                            ),
                            CategoryCard(
                              color: Colors.pinkAccent,
                              title: 'Letters',
                              subtitle: 'Learn the alphabet!',
                              iconPath: 'assets/icons/letters_icon.png',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final Color? color;
  final String title;
  final String subtitle;
  final String iconPath;

  CategoryCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.iconPath,
  });

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200), // Duration of the tap animation
      lowerBound: 0.95, // Slightly scale down when tapped
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // Navigate to SwipePageView and set initial page index based on category
  void navigateToPage(BuildContext context) {
    int initialPageIndex = 0; // Default to Numbers
    if (widget.title == 'Shapes') {
      initialPageIndex = 1;
    } else if (widget.title == 'Letters') {
      initialPageIndex = 2;
    } else if (widget.title == 'Colors') {
      initialPageIndex = 3;
    }

    // Navigate to the SwipePageView with the initialPageIndex
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SwipePageView(initialPageIndex: initialPageIndex)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) => _scaleController.forward(),
      onTapCancel: () => _scaleController.forward(),
      onTap: () {
        navigateToPage(context);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.025,
            horizontal: screenWidth * 0.05,
          ),
          decoration: BoxDecoration(
            color: widget.color ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Image (Left) with no background color
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  widget.iconPath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: screenWidth * 0.05),

              // Text (Right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        color: Colors.grey[700],
                      ),
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
