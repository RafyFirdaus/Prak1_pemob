import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'card_flip_effect.dart';
import 'game_over_screen.dart';
import 'view_model.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final QuizViewModel viewModel = QuizViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Quiz'),
            actions: [
              TextButton(
                onPressed:
                    viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                    ? viewModel.getNextQuestion
                    : null,
                child: const Text('Berikutnya'),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OpenContainer(
                        tappable: false,
                        closedElevation: 0,
                        closedColor: colors.surface,
                        openColor: colors.surface,
                        transitionDuration: const Duration(milliseconds: 700),
                        openBuilder: (context, closeContainer) =>
                            GameOverScreen(
                              score: viewModel.score,
                              totalQuestions: viewModel.totalQuestions,
                            ),
                        closedBuilder: (context, openContainer) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            QuestionCard(
                              question: viewModel.currentQuestion?.question,
                            ),
                            if (viewModel.isGameOver)
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: FilledButton.icon(
                                  onPressed: openContainer,
                                  icon: const Icon(Icons.insights_rounded),
                                  label: const Text('Lihat hasil'),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Pilih satu jawaban',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AnswerCards(
                        questionKey: viewModel.currentQuestion?.question ?? '',
                        onTapped: viewModel.checkAnswer,
                        answers:
                            viewModel.currentQuestion?.possibleAnswers ?? [],
                        selectedAnswer: viewModel.selectedAnswer,
                        didAnswer: viewModel.didAnswerQuestion,
                        correctAnswer: viewModel.didAnswerQuestion
                            ? viewModel.currentQuestion?.correctAnswer
                            : null,
                      ),
                      if (viewModel.didAnswerQuestion)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            viewModel.selectedAnswer ==
                                    viewModel.currentQuestion?.correctAnswer
                                ? 'Benar! Energi bertambah.'
                                : 'Belum tepat. Jawaban benar ditandai hijau.',
                          ),
                        ),
                      const SizedBox(height: 16),
                      StatusBar(viewModel: viewModel),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuestionCard extends StatelessWidget {
  const QuestionCard({required this.question, super.key});
  final String? question;

  @override
  Widget build(BuildContext context) {
    // Final module step replaces AnimatedSwitcher with PageTransitionSwitcher.
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 400),
      layoutBuilder: (entries) =>
          Stack(alignment: Alignment.topCenter, children: entries),
      transitionBuilder: (child, animation, secondaryAnimation) {
        final curved = CurveTween(curve: Curves.easeInCubic).animate(animation);
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
      child: Card(
        key: ValueKey(question),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              question ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}

class AnswerCards extends StatelessWidget {
  const AnswerCards({
    required this.questionKey,
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.didAnswer,
    super.key,
  });
  final String questionKey;
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;
  final int? selectedAnswer;
  final bool didAnswer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio:
            (constraints.maxWidth - 12) /
            2 /
            (MediaQuery.textScalerOf(context).scale(100) + 28),
        children: List.generate(answers.length, (index) {
          final colors = Theme.of(context).colorScheme;
          final correct = correctAnswer == index;
          final wrong = selectedAnswer == index && !correct;
          final background = correct
              ? Colors.green.shade100
              : wrong
              ? colors.errorContainer
              : colors.primaryContainer;
          final foreground = correct
              ? Colors.green.shade900
              : wrong
              ? colors.onErrorContainer
              : colors.onPrimaryContainer;
          return CardFlipEffect(
            delayAmount: index.toDouble() / 2,
            child: Card.filled(
              key: ValueKey('$questionKey:$index'),
              color: background,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: didAnswer ? null : () => onTapped(index),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (correct || wrong)
                        Icon(
                          correct ? Icons.check_circle : Icons.cancel,
                          color: foreground,
                          size: 20,
                        ),
                      Flexible(
                        child: Text(
                          answers[index],
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class StatusBar extends StatelessWidget {
  const StatusBar({required this.viewModel, super.key});
  final QuizViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Soal ${viewModel.answeredQuestionCount} / ${viewModel.totalQuestions} · Skor: ${viewModel.score}',
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(
                viewModel.totalQuestions,
                (index) => AnimatedScoreIcon(isActive: index < viewModel.score),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedScoreIcon extends StatelessWidget {
  const AnimatedScoreIcon({required this.isActive, super.key});
  final bool isActive;
  static const _duration = Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1 : 0.5,
      duration: _duration,
      curve: Curves.elasticOut,
      child: TweenAnimationBuilder<Color?>(
        duration: _duration,
        curve: Curves.easeOutCubic,
        tween: ColorTween(
          begin: Colors.grey.shade400,
          end: isActive ? Colors.indigo : Colors.grey.shade400,
        ),
        builder: (context, color, child) => Icon(
          Icons.bolt_rounded,
          size: 48,
          color: color,
          semanticLabel: isActive ? 'Poin diperoleh' : 'Poin belum diperoleh',
        ),
      ),
    );
  }
}
