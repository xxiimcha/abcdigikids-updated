import 'package:flutter/material.dart';
import '../../../widgets/_pageswipe.dart';
import '../../../widgets/settings_button.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  Future<void> _goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        await _goBack();
        return false;
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.transparent),
            titleTextStyle: TextStyle(color: Colors.transparent),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: SizedBox.shrink(), // Removes default AppBar
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Background
                Positioned.fill(
                  child: Image.asset(
                    'assets/backgrounds/chalkboard.gif',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
                // Custom Back Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: _goBack,
                  ),
                ),
                // Settings Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: SettingsButton(),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.only(top: 70.0, left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
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
              ],
            ),
          ),
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
      duration: Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void navigateToPage(BuildContext context) {
    int initialPageIndex = 0;
    if (widget.title == 'Shapes') {
      initialPageIndex = 1;
    } else if (widget.title == 'Letters') {
      initialPageIndex = 2;
    } else if (widget.title == 'Colors') {
      initialPageIndex = 3;
    }

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
              Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                child: Image.asset(
                  widget.iconPath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: screenWidth * 0.05),
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
