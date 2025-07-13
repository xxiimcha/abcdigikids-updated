import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/utils/routes.dart';
import 'pages/login_page.dart';
import 'package:provider/provider.dart';
import 'pages/utils/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔵 Step 1: Flutter binding initialized");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🟢 Step 2: Firebase initialized successfully");
  } catch (e, stack) {
    print("🔴 Firebase init failed: $e");
    print("🔴 Stacktrace: $stack");
  }

  print("🟢 Step 3: Running the app");

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
  debugShowCheckedModeBanner: false,
  title: 'ABCDigiKids',
  theme: ThemeData(primarySwatch: Colors.blue),
  initialRoute: AppRoutes.login,
  onGenerateRoute: (settings) {
    final mutedRoutes = {
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.profileSelection,
    };

    final routeName = settings.name ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mutedRoutes.contains(routeName)) {
        settingsProvider.stopMusic();
      } else {
        if (settingsProvider.isMusicOn) {
          settingsProvider.resumeMusic();
        }
      }
    });

    // ✅ Use your custom route handler
    return AppRoutes.onGenerateRoute(settings);
  },
);

  }
}
