import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    required this.score,
    required this.totalQuestions,
    super.key,
  });
  final int score;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil kuis')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 88, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Kuis selesai!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              // Extra animation: count the final score up from zero.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score.toDouble()),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Text(
                  '${value.round()} / $totalQuestions',
                  key: const ValueKey('final-score'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                score == totalQuestions
                    ? 'Sempurna! Semua jawaban benar.'
                    : 'Terus berlatih dan coba lagi!',
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
