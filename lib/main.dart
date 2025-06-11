import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/utils/routes.dart';
import 'pages/login_page.dart';
import 'package:provider/provider.dart';
import 'pages/utils/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("❌ Firebase init failed: $e");
  }

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
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? '';
        final routeBuilder = AppRoutes.routes[routeName];

        final mutedRoutes = {
          AppRoutes.login,
          AppRoutes.signup,
          AppRoutes.profileSelection,
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mutedRoutes.contains(routeName)) {
            settingsProvider.stopMusic();
          } else {
            if (settingsProvider.isMusicOn) {
              settingsProvider.resumeMusic();
            }
          }
        });

        if (routeBuilder != null) {
          return MaterialPageRoute(builder: routeBuilder, settings: settings);
        }

        // fallback route
        return MaterialPageRoute(builder: (context) => LoginPage());
      },
    );
  }
}
