import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ColorsQuizPage extends StatefulWidget {
  @override
  _ColorsQuizPageState createState() => _ColorsQuizPageState();
}

class _ColorsQuizPageState extends State<ColorsQuizPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, dynamic>> _questions = [
    {
      'image': 'assets/learn_colors/red.png',
      'options': ['Red', 'Blue', 'Green'],
      'answer': 'Red',
    },
    {
      'image': 'assets/learn_colors/blue.png',
      'options': ['Yellow', 'Blue', 'Red'],
      'answer': 'Blue',
    },
    {
      'image': 'assets/learn_colors/green.png',
      'options': ['Green', 'Blue', 'Yellow'],
      'answer': 'Green',
    },
  ];

  int _currentQuestion = 0;
  bool _showFeedback = false;
  String _feedbackMessage = '';

  void _checkAnswer(String selectedOption) {
    setState(() {
      if (selectedOption == _questions[_currentQuestion]['answer']) {
        _feedbackMessage = 'Correct!';
        _flutterTts.speak("Correct! This is ${selectedOption}");
      } else {
        _feedbackMessage = 'Try again!';
        _flutterTts.speak("Try again!");
      }
      _showFeedback = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showFeedback = false;
        if (_currentQuestion < _questions.length - 1) {
          _currentQuestion++;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Color Quiz")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_questions[_currentQuestion]['image'], height: 200),
          SizedBox(height: 20),
          _showFeedback
              ? Text(_feedbackMessage, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              : Column(
                  children: _questions[_currentQuestion]['options'].map<Widget>((option) {
                    return ElevatedButton(
                      onPressed: () => _checkAnswer(option),
                      child: Text(option),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
