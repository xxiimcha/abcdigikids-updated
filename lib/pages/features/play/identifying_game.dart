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
  Set<int> selectedIndexes = {}; 
  int score = 0;
  int timeLeft = 60;
  Timer? _timer;
  FlutterTts _flutterTts = FlutterTts();
  bool musicOn = true;
  bool soundOn = true;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.2);
    await _flutterTts.setSpeechRate(0.5);
    await _selectChildFriendlyVoice();
  }

  Future<void> _selectChildFriendlyVoice() async {
    List<dynamic> voices = await _flutterTts.getVoices;
    for (var voice in voices) {
      if (voice.toString().contains("child") || voice.toString().contains("kids")) {
        await _flutterTts.setVoice(voice);
        break;
      }
    }
  }

  Future<void> _speakInstructions() async {
    if (soundOn) {
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.speak(
          "Hello! Welcome to the Identifying Game. Find the letter shown at the top and tap all matching ones. Good luck!");
    }
    _startTimer();
  }

  void _startGame() {
    _generateNewTarget();
    _speakInstructions();
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
      targetLetter = String.fromCharCode(65 + Random().nextInt(26));
      gridLetters = List.generate(9, (_) => String.fromCharCode(65 + Random().nextInt(26)));
      int targetInstances = 1 + Random().nextInt(3);
      for (int i = 0; i < targetInstances; i++) {
        int randomIndex = Random().nextInt(9);
        gridLetters[randomIndex] = targetLetter;
      }
      selectedIndexes.clear();
    });
  }

  void _checkSelection(int index) {
    if (gridLetters[index] == targetLetter && !selectedIndexes.contains(index)) {
      setState(() {
        selectedIndexes.add(index);
        if (selectedIndexes.length == gridLetters.where((letter) => letter == targetLetter).length) {
          score++;
          _generateNewTarget();
        }
      });
    }
  }

  void _resetGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      _generateNewTarget();
    });
    _speakInstructions();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Time's up!", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Your final score is $score."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: Text("Restart"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Continue"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text("Back to Menu"),
          ),
        ],
      ),
    );
  }
void _showSettingsDialog() {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Music:"),
              Switch(
                value: musicOn,
                onChanged: (value) {
                  setState(() {
                    musicOn = value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sound:"),
              Switch(
                value: soundOn,
                onChanged: (value) {
                  setState(() {
                    soundOn = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            _resetGame();
          },
          child: Text("Restart"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text("Continue"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
          child: Text("Back to Menu"),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Score: $score", style: TextStyle(fontSize: 24, color: Colors.white)),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: _showSettingsDialog,
                  ),
                  Text("Time: $timeLeft", style: TextStyle(fontSize: 24, color: Colors.white)),
                ],
              ),
              SizedBox(height: 20),
              Text("Find all: $targetLetter", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange)),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: gridLetters.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _checkSelection(index);
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: selectedIndexes.contains(index) ? Colors.green : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            gridLetters[index],
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }
}
