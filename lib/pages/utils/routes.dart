import 'package:flutter/material.dart';
import '../login_page.dart'; // Adjust the path based on your file structure
import '../home_screen.dart'; // Import HomeScreen (if needed)
import '../features/speak/talk_screen.dart'; // Import TalkScreen
import '../features/learn/learn_screen.dart'; // Import LearnScreen
import '../signup_page.dart'; // Import SignupPage (you'll need to create this)
import '../profile_selection_page.dart'; // Import ProfileSelectionPage (you'll need to create this)
import '../features/play/play_screen.dart'; // Import PlayScreen
import '../features/play/memory_match_game.dart'; // Import Memory Match game
import '../features/play/puzzle_game.dart'; // Import Puzzle Game
import '../features/play/quiz_game.dart'; // Import Quiz Game
import '../features/play/identifying_game.dart'; // Import Quiz Game
import '../features/play/matching_game.dart'; // Import Quiz Game
import '../features/play/matching_game_selection.dart'; // Import Quiz Game

class AppRoutes {
  static const String login = '/login'; // Route for the login screen
  static const String signup = '/signup'; // Route for the signup screen
  static const String profileSelection = '/profileSelection'; // Route for the profile selection screen
  static const String talk = '/talk';   // Route for the talk screen
  static const String learn = '/learn'; // Route for LearnScreen
  static const String home = '/home';   // Route for the home screen
  static const String play = '/play';   // Route for PlayScreen
  static const String memoryMatch = '/memory_match'; // Route for Memory Match game
  static const String puzzleGame = '/puzzle_game';   // Route for Puzzle Game
  static const String quizGame = '/quiz_game';       // Route for Quiz Game
  static const String identifyingGame = '/identifying_game';       // Route for Quiz Game
  static const String matchingGame = '/matching_game';
  static const String matchingGameSelection = '/matching_game_selection';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(), // Define the login route
    signup: (context) => SignupPage(), // Define the signup screen route
    profileSelection: (context) => ProfileSelectionPage(), // Define the profile selection route
    home: (context) => HomeScreen(profileName: 'User'), // Define the home screen route
    talk: (context) => TalkScreen(), // Define the talk screen route
    learn: (context) => LearnScreen(), // Add LearnScreen route
    play: (context) => PlayScreen(), // Add PlayScreen route
    memoryMatch: (context) => MemoryMatchGame(), // Add Memory Match Game route
    puzzleGame: (context) => PuzzleGame(), // Add Puzzle Game route
    quizGame: (context) => QuizGame(), // Add Quiz Game route
    identifyingGame: (context) => IdentifyingGame (), // Add Quiz Game route
    matchingGame: (context) => MatchingGame(category: 'Others'), // Pass category as a named parameter
    matchingGameSelection: (context) => CategorySelectionScreen(), // Add the matching game screen here
  };
  
  static const Set<String> mutedRoutes = {
    login,
    signup,
    profileSelection,
  };

}
