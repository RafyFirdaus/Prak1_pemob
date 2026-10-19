import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/main.dart';
import 'package:quiz/model.dart';
import 'package:quiz/question_screen.dart';
import 'package:quiz/view_model.dart';

void main() {
  test(
    'Answers count once, questions cannot be skipped, and game ends once',
    () {
      final quiz = QuizViewModel();
      addTearDown(quiz.dispose);
      final first = quiz.currentQuestion;
      quiz.getNextQuestion();
      expect(quiz.currentQuestion, same(first));
      quiz.checkAnswer(-1);
      expect(quiz.didAnswerQuestion, isFalse);
      for (var i = 0; i < quiz.totalQuestions; i++) {
        final correct = quiz.currentQuestion!.correctAnswer;
        quiz.checkAnswer(correct);
        quiz.checkAnswer(correct);
        expect(quiz.score, i + 1);
        if (i < quiz.totalQuestions - 1) quiz.getNextQuestion();
      }
      expect(quiz.isGameOver, isTrue);
      quiz.getNextQuestion();
      expect(quiz.isGameOver, isTrue);
      expect(quiz.answeredQuestionCount, quiz.totalQuestions);
    },
  );

  test('Wrong answer locks selection without awarding a point', () {
    final quiz = QuizViewModel();
    addTearDown(quiz.dispose);
    final correct = quiz.currentQuestion!.correctAnswer;
    final wrong = (correct + 1) % quiz.currentQuestion!.possibleAnswers.length;
    quiz.checkAnswer(wrong);
    quiz.checkAnswer(correct);
    expect(quiz.score, 0);
    expect(quiz.selectedAnswer, wrong);
    quiz.getNextQuestion();
    expect(quiz.selectedAnswer, isNull);
    expect(quiz.didAnswerQuestion, isFalse);
  });

  for (final size in [const Size(320, 640), const Size(740, 360)]) {
    testWidgets('Complete quiz, flip cards, show result and restart at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bank = QuestionBank();
      final questions = <String, Question>{};
      while (bank.hasNextQuestion) {
        final question = bank.getRandomQuestion()!;
        questions[question.question] = question;
      }
      await tester.pumpWidget(const MainApp());
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      for (var i = 0; i < questions.length; i++) {
        final card = tester.widget<QuestionCard>(find.byType(QuestionCard));
        final question = questions[card.question]!;
        final answer = find.text(
          question.possibleAnswers[question.correctAnswer],
        );
        await tester.ensureVisible(answer);
        await tester.tap(answer);
        await tester.pumpAndSettle();
        expect(find.text('Benar! Energi bertambah.'), findsOneWidget);
        if (i < questions.length - 1) {
          await tester.tap(find.text('Berikutnya'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
          await tester.pumpAndSettle();
        }
      }
      final result = find.text('Lihat hasil');
      await tester.ensureVisible(result);
      await tester.tap(result);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('final-score')), findsOneWidget);
      expect(
        find.text('${questions.length} / ${questions.length}'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Kembali ke beranda'));
      await tester.tap(find.text('Kembali ke beranda'));
      await tester.pumpAndSettle();
      expect(find.text('New Game'), findsOneWidget);
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      expect(
        find.text('Soal 1 / ${questions.length} · Skor: 0'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
