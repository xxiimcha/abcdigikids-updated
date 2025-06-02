import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_selection_page.dart';
import '../widgets/settings_button.dart';

class CreateProfilePage extends StatefulWidget {
  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _pinRequired = false;
  bool _isCreating = false;

  late AnimationController _avatarController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _bounceAnimation = CurvedAnimation(
      parent: _avatarController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _avatarController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  void _createProfile() async {
    String name = nameController.text.trim();
    String birthday = birthdayController.text.trim();
    String pin = pinController.text.trim();
    User? user = _auth.currentUser;

    if (name.isEmpty || birthday.isEmpty || (_pinRequired && pin.isEmpty)) {
      _showError('Please fill in all required fields');
      return;
    }

    if (user == null) {
      _showError('User not logged in. Please log in and try again.');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await _firestore.collection('app_profiles').add({
        'userId': user.uid,
        'name': name,
        'birthday': birthday,
        'pin': _pinRequired ? pin : null,
        'createdAt': Timestamp.now(),
      });

      _showSuccess('Profile created successfully!');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileSelectionPage()));
    } catch (e) {
      _showError('Error creating profile. Please try again.');
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
            child: Container(color: Colors.blueAccent.withOpacity(0.5)),
          ),
          // Back button and Settings button in SafeArea
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ⬅️ Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SettingsButton(),
                ],
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
                    'Let’s Create Your Profile!',
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ComicSans',
                      shadows: [Shadow(blurRadius: 5, color: Colors.black54)],
                    ),
                  ),
                  SizedBox(height: 20),
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: GestureDetector(
                      onTap: () {
                        // Future avatar picker
                      },
                      child: Container(
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
                    ),
                  ),
                  SizedBox(height: 20),
                  Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.2),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildRoundedTextField(nameController, 'Profile Name', Icons.person),
                          SizedBox(height: 15),
                          _buildRoundedTextField(
                            birthdayController,
                            'Birthday (MM/DD/YYYY)',
                            Icons.cake,
                            keyboardType: TextInputType.datetime,
                          ),
                          SizedBox(height: 15),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: Text(
                                    'Require PIN for this profile',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  value: _pinRequired,
                                  activeColor: Colors.orangeAccent,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _pinRequired = value;
                                    });
                                  },
                                ),
                                if (_pinRequired)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: _buildRoundedTextField(
                                      pinController,
                                      'Enter PIN',
                                      Icons.lock,
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: _createProfile,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
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
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: _isCreating
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline, color: Colors.white, size: 26),
                                        SizedBox(width: 12),
                                        Text(
                                          'Create Profile',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedTextField(TextEditingController controller, String hintText, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
