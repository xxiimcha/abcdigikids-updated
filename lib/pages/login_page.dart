import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'signup_page.dart';
import 'profile_selection_page.dart';
import 'create_profile_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isMusicOn = true;

  @override
  void initState() {
    super.initState();
    _loadMusicSetting();
  }

  Future<void> _loadMusicSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMusicOn = prefs.getBool('music') ?? true;
    });
  }

  Future<void> _toggleMusicSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music', value);
    setState(() {
      _isMusicOn = value;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Settings"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Background Music"),
            Switch(
              value: _isMusicOn,
              onChanged: (value) {
                _toggleMusicSetting(value);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in both email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _checkForProfiles(userCredential.user?.uid);
    } catch (e) {
      _showError('Invalid email or password');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkForProfiles(String? userId) async {
    if (userId == null) {
      _showError('User ID is null. Please try again.');
      return;
    }

    try {
      QuerySnapshot profileSnapshot = await _firestore
          .collection('app_profiles')
          .where('userId', isEqualTo: userId)
          .get();

      if (profileSnapshot.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSelectionPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateProfilePage()),
        );
      }
    } catch (e) {
      _showError('Error checking profiles. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/background.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: _showSettingsDialog,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                    ),
                  ),
                  SizedBox(height: 20),
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.15),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.email, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.lock, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: _isLoading ? null : _login,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.purpleAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          'Logging In...',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, color: Colors.white, size: 22),
                                        SizedBox(width: 10),
                                        Text(
                                          'Login',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      'Don’t have an account? Sign up',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
