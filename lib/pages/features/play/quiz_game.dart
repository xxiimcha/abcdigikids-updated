import 'package:flutter/material.dart';

class QuizGame extends StatefulWidget {
  @override
  _QuizGameState createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  // Sample quiz data
  final List<Map<String, Object>> _questions = [
    {
      'question': 'What color is the sky? 🌈',
      'answers': [
        {'text': '🔵 Blue', 'isCorrect': true},
        {'text': '🟢 Green', 'isCorrect': false},
        {'text': '🔴 Red', 'isCorrect': false},
        {'text': '⚪ White', 'isCorrect': false},
      ],
    },
    {
      'question': 'Which animal says "Meow"? 🐾',
      'answers': [
        {'text': '🐶 Dog', 'isCorrect': false},
        {'text': '🐱 Cat', 'isCorrect': true},
        {'text': '🐰 Rabbit', 'isCorrect': false},
        {'text': '🐥 Chick', 'isCorrect': false},
      ],
    },
    {
      'question': 'What number comes after 2? 🔢',
      'answers': [
        {'text': '1️⃣ One', 'isCorrect': false},
        {'text': '2️⃣ Two', 'isCorrect': false},
        {'text': '3️⃣ Three', 'isCorrect': true},
        {'text': '4️⃣ Four', 'isCorrect': false},
      ],
    },
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool _isCorrectAnswer = false;

  void _answerQuestion(bool isCorrect) {
    if (_isAnswered) return; // Prevent answering the same question multiple times

    setState(() {
      _isAnswered = true;
      _isCorrectAnswer = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });

    // Move to the next question after a short delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isAnswered = false;
        _isCorrectAnswer = false;
        _currentQuestionIndex++;
        if (_currentQuestionIndex >= _questions.length) {
          _showResult();
        }
      });
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('🎉 Yay! Quiz Completed!'),
        content: Text('Your score is $_score out of ${_questions.length}. Well done! 🎈'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetQuiz();
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

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _isCorrectAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/chalkboard.gif', // Update with the correct path
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    currentQuestion['question'] as String,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: (currentQuestion['answers'] as List<Map<String, Object>>).map((answer) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAnswered
                                  ? (answer['isCorrect'] as bool
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.pinkAccent,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (!_isAnswered) {
                                _answerQuestion(answer['isCorrect'] as bool);
                              }
                            },
                            child: Text(
                              answer['text'] as String,
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_isAnswered)
                    Center(
                      child: Text(
                        _isCorrectAnswer ? '🎉 Great job!' : '😅 Oops, try again!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _isCorrectAnswer ? Colors.green : Colors.red,
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
