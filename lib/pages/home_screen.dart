import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart'; // For smooth transitions
import 'utils/routes.dart'; // Import routes
import '../pages/features/learn/learn_screen.dart'; 
import '../pages/features/play/play_screen.dart'; 
import '../pages/features/speak/talk_screen.dart';

class HomeScreen extends StatefulWidget {
  final String profileName;

  HomeScreen({required this.profileName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeScreen(),
      TalkScreen(),
      LearnScreen(),
    ];

    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      lowerBound: 0.85,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlayScreen()), // Navigate to PlayScreen
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LearnScreen()), // Navigate to LearnScreen
      );
    }
  }


  Widget _buildHomeScreen() {
    return Container(
      width: double.infinity, // Ensure full width
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.shade100, Colors.teal.shade300],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView( // Avoid overflow issues
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
            children: [
              _buildProfileCard(),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Explore, play, and learn with fun activities!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
              SizedBox(height: 40),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileCard() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
        ),
        SizedBox(height: 15),
        Text(
          'Welcome, ${widget.profileName}!',
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionButton(Icons.videogame_asset, "Play", Colors.orangeAccent, 0),
        _buildActionButton(Icons.mic, "Talk", Colors.teal, 1),
        _buildActionButton(Icons.menu_book, "Learn", Colors.blue, 2),
        _buildActionButton(Icons.auto_stories, "Storytelling", Colors.purple, 3), // New Storytelling button
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Builder(
          builder: (context) {
            double buttonWidth = MediaQuery.of(context).size.width * 0.7; // Move inside build
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: buttonWidth,
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: DefaultTextStyle(
            key: ValueKey<int>(_selectedIndex),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            child: Text(_getAppBarTitle()),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_selectedIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Talk';
      case 2:
        return 'Learn';
      default:
        return 'App';
    }
  }
}
