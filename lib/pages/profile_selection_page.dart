import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // Import HomeScreen
import 'create_profile_page.dart'; // Import CreateProfilePage
import 'utils/settings.dart'; // ✅ Import SettingsButton
import '../widgets/settings_button.dart'; // Adjust path as needed

class ProfileSelectionPage extends StatefulWidget {
  @override
  _ProfileSelectionPageState createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> profiles = [];
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    User? user = _auth.currentUser;
    if (user == null) {
      _controller.forward();
      return;
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('app_profiles')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        profiles = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        isLoading = false;
      });

      _controller.forward();
    } catch (e) {
      print('Error fetching profiles: $e');
      setState(() {
        isLoading = false;
      });
      _controller.forward();
    }
  }

Future<bool> _showPinInput(BuildContext context, String profileName, String correctPin) async {
  String enteredPin = '';
  bool isValid = false;

  await showModalBottomSheet(
    context: context,
    isDismissible: false,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter PIN for $profileName',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontFamily: 'ComicSans',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '4-digit PIN',
                    hintStyle: TextStyle(
                      color: Colors.deepPurple.withOpacity(0.6),
                      fontSize: 16,
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    enteredPin = value;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.cancel, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[500],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'ComicSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (enteredPin == correctPin) {
                            isValid = true;
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Incorrect PIN'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        label: Text(
                          'Enter',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'ComicSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );

  return isValid;
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          // ✅ Add reusable settings button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: SettingsButton(),
              ),
            ),
          ),
          Center(
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wanna Play?',
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ComicSans',
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.black54),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        profiles.isEmpty
                            ? Text(
                                'No profile created',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: profiles.length,
                                itemBuilder: (context, index) {
                                  var profile = profiles[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      if (profile['pin'] != null && profile['pin'].toString().isNotEmpty) {
                                        bool isCorrect = await _showPinInput(context, profile['name'], profile['pin']);
                                        if (isCorrect) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomeScreen(profileName: profile['name'])),
                                          );
                                        }
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => HomeScreen(profileName: profile['name'])),
                                        );
                                      }
                                    },

                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.yellowAccent, width: 4),
                                            image: DecorationImage(
                                              image: AssetImage('assets/profile_placeholder.jpg'),
                                              fit: BoxFit.cover,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.yellow.withOpacity(0.6),
                                                blurRadius: 10,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          profile['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'ComicSans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateProfilePage()),
                            );
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.pinkAccent, Colors.orangeAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
                                SizedBox(width: 12),
                                Text(
                                  profiles.isEmpty ? 'Create Profile' : 'Add Profile',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'ComicSans',
                                  ),
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
    );
  }
}
