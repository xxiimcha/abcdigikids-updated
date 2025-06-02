import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/utils/routes.dart';
import 'pages/login_page.dart';
import 'package:provider/provider.dart';
import 'pages/utils/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: ABCDigiKidsApp(),
    ),
  );
}

class ABCDigiKidsApp extends StatefulWidget {
  @override
  _ABCDigiKidsAppState createState() => _ABCDigiKidsAppState();
}

class _ABCDigiKidsAppState extends State<ABCDigiKidsApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      settingsProvider.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      settingsProvider.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABCDigiKids',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.login,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    final routeBuilder = AppRoutes.routes[routeName];
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    const mutedRoutes = {
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.profileSelection,
    };

    if (mutedRoutes.contains(routeName)) {
      settingsProvider.stopMusic();
    } else {
      if (settingsProvider.isMusicOn) {
        settingsProvider.resumeMusic();
      }
    }

    if (routeBuilder != null) {
      return MaterialPageRoute(builder: routeBuilder, settings: settings);
    }

    return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
