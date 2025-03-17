import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

class IdentifyingGame extends StatefulWidget {
  @override
  _IdentifyingGameState createState() => _IdentifyingGameState();
}

class _IdentifyingGameState extends State<IdentifyingGame> {
  String targetLetter = '';
  List<String> gridLetters = [];
  Set<int> selectedIndexes = {}; // To track the indexes of selected tiles
  int score = 0;
  int timeLeft = 60; // 60 seconds for the game
  Timer? _timer;

  // Initialize Flutter TTS
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop(); // Stop any ongoing TTS when disposing the widget
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.2); // Higher pitch for a child-like sound
    await _flutterTts.setSpeechRate(0.5); // Slower speech rate for clarity
    await _selectChildFriendlyVoice(); // Attempt to select a child-friendly voice
  }

  Future<void> _selectChildFriendlyVoice() async {
    List<dynamic> voices = await _flutterTts.getVoices;

    // Try to find a child-friendly voice if available
    for (var voice in voices) {
      if (voice.toString().contains("child") || voice.toString().contains("kids")) {
        await _flutterTts.setVoice(voice);
        break;
      }
    }
  }

  Future<void> _speakInstructions() async {
    // Set the awaitSpeakCompletion to true to wait for the speech to complete
    await _flutterTts.awaitSpeakCompletion(true);

    await _flutterTts.speak(
        "Hello! Welcome to the Identifying Game. Can you find the letter shown at the top of the screen in the grid? Tap all the matching letters. Good luck!");

    // After speaking, start the timer
    _startTimer();
  }

  void _startGame() {
    _generateNewTarget();
    _speakInstructions(); // Speak the instructions when the game starts
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          _showGameOverDialog();
        }
      });
    });
  }

  void _generateNewTarget() {
    setState(() {
      targetLetter = String.fromCharCode(65 + Random().nextInt(26)); // Random letter A-Z
      gridLetters = List.generate(9, (_) => String.fromCharCode(65 + Random().nextInt(26)));
      
      // Ensure multiple occurrences of the target letter appear in the grid
      int numberOfTargetLetters = 1 + Random().nextInt(3); // 1 to 3 instances
      for (int i = 0; i < numberOfTargetLetters; i++) {
        int randomIndex = Random().nextInt(9);
        gridLetters[randomIndex] = targetLetter;
      }

      // Reset the selected indexes for the new target
      selectedIndexes.clear();
    });
  }

  void _checkSelection(int index) {
    if (gridLetters[index] == targetLetter && !selectedIndexes.contains(index)) {
      setState(() {
        selectedIndexes.add(index);

        // If all instances of the target letter are selected
        if (selectedIndexes.length == gridLetters.where((letter) => letter == targetLetter).length) {
          score++;
          _generateNewTarget();
        }
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Time\'s up!'),
        content: Text('Your final score is $score.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      _generateNewTarget();
    });
    _speakInstructions(); // Speak the instructions again when the game resets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/chalkboard.gif', // Make sure the path is correct
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Score and Timer Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Time: $timeLeft',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Target Letter
                  Text(
                    'Find all: $targetLetter',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Grid of Letters
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: gridLetters.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _checkSelection(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedIndexes.contains(index) ? Colors.green : Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                gridLetters[index],
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
