import 'package:flutter/cupertino.dart';
import 'model.dart';

class QuizViewModel extends ChangeNotifier {
  final QuestionBank _questionBank = QuestionBank();
  late final int totalQuestions;
  Question? currentQuestion;
  int answeredQuestionCount = 0;
  int score = 0;
  bool didAnswerQuestion = false;
  bool get hasNextQuestion => answeredQuestionCount < totalQuestions;
  bool get isGameOver => didAnswerQuestion && !hasNextQuestion;
  int? selectedAnswer;

  QuizViewModel() {
    totalQuestions = _questionBank.remainingQuestions;
    getNextQuestion();
  }

  void getNextQuestion() {
    if (currentQuestion != null && !didAnswerQuestion) return;
    if (!_questionBank.hasNextQuestion) return;
    currentQuestion = _questionBank.getRandomQuestion();
    answeredQuestionCount++;

    didAnswerQuestion = false;
    selectedAnswer = null;

    notifyListeners();
  }

  void checkAnswer(int selectedIndex) {
    if (didAnswerQuestion || currentQuestion == null) return;
    if (selectedIndex < 0 ||
        selectedIndex >= currentQuestion!.possibleAnswers.length) {
      return;
    }
    selectedAnswer = selectedIndex;
    if (currentQuestion?.correctAnswer == selectedIndex) {
      score++;
    }

    didAnswerQuestion = true;

    notifyListeners();
  }
}
