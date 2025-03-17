import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/utils/routes.dart'; // Import routes
import 'services/music.service.dart'; // Import the music service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ABCDigiKidsApp());
}

class ABCDigiKidsApp extends StatefulWidget {
  @override
  _ABCDigiKidsAppState createState() => _ABCDigiKidsAppState();
}

class _ABCDigiKidsAppState extends State<ABCDigiKidsApp> with WidgetsBindingObserver {
  final MusicService _musicService = MusicService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen to lifecycle changes
    _musicService.playBackgroundMusic(); // Start playing background music when app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _musicService.stopMusic(); // Stop the music when the app is disposed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _musicService.pauseMusic(); // Pause music when app goes to background
    } else if (state == AppLifecycleState.resumed) {
      _musicService.playBackgroundMusic(); // Resume music when app returns to foreground
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABCDigiKids',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.login, // Set initial route to LoginPage
      routes: AppRoutes.routes, // Use the routes from routes.dart
      onGenerateRoute: _onGenerateRoute, // Handle custom route logic for music
    );
  }

  // Custom method to handle route changes and stop/play music accordingly
  Route _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
      case AppRoutes.signup:
      case AppRoutes.profileSelection:
        _musicService.stopMusic(); // Stop music on login, signup, and profile selection pages
        break;
      default:
        _musicService.playBackgroundMusic(); // Play music on all other pages
    }
    return MaterialPageRoute(
      builder: (context) => AppRoutes.routes[settings.name]!(context),
    );
  }
}
