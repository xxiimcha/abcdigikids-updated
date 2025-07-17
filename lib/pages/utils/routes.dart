import 'package:flutter/material.dart';
import '../login_page.dart';
import '../home_screen.dart';
import '../features/speak/talk_screen.dart';
import '../features/learn/learn_screen.dart';
import '../signup_page.dart';
import '../profile_selection_page.dart';
import '../features/play/play_screen.dart';
import '../features/play/memory_match_game.dart';
import '../features/play/puzzle_game.dart';
import '../features/play/quiz_game.dart';
import '../features/play/identifying_game.dart';
import '../features/play/matching_game.dart';
import '../features/play/matching_game_selection.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileSelection = '/profileSelection';
  static const String talk = '/talk';
  static const String learn = '/learn';
  static const String home = '/home';
  static const String play = '/play';
  static const String memoryMatch = '/memory_match';
  static const String puzzleGame = '/puzzle_game';
  static const String quizGame = '/quiz_game';
  static const String identifyingGame = '/identifying_game';
  static const String matchingGame = '/matching_game';
  static const String matchingGameSelection = '/matching_game_selection';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());

      case signup:
        return MaterialPageRoute(builder: (_) => SignupPage());

      case profileSelection:
        return MaterialPageRoute(builder: (_) => ProfileSelectionPage());

      case home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            profileName: args['profileName'],
            profileId: args['profileId'],
            userId: args['userId'],
          ),
        );

      case talk:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TalkScreen(
            profileName: args['profileName'],
            profileId: args['profileId'],
            userId: args['userId'],
          ),
        );

      case learn:
        return MaterialPageRoute(builder: (_) => LearnScreen());

      case play:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PlayScreen(
        
            profileName: args['profileName'],
            profileId: args['profileId'],
            userId: args['userId']
        ),);

      case memoryMatch:
        return MaterialPageRoute(builder: (_) => MemoryMatchGame());

      case puzzleGame:
        return MaterialPageRoute(builder: (_) => PuzzleGame());

      case quizGame:
        return MaterialPageRoute(builder: (_) => QuizGame());

      case identifyingGame:
        return MaterialPageRoute(builder: (_) => IdentifyingGame());

      case matchingGame:
        return MaterialPageRoute(
          builder: (_) => MatchingGame(category: 'Others'),
        );

      case matchingGameSelection:
        return MaterialPageRoute(builder: (_) => CategorySelectionScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static const Set<String> mutedRoutes = {
    login,
    signup,
    profileSelection,
  };
}
