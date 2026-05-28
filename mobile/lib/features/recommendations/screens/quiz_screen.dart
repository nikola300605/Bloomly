import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

const _questions = [
  _Question(
    text: 'Where will your plant live?',
    key: 'location',
    options: [
      _Option('🏠', 'Indoor', 'room, shelf, desk'),
      _Option('🌤', 'Balcony', 'semi-outdoor'),
      _Option('🌳', 'Outdoor', 'garden or yard'),
      _Option('🚿', 'Bathroom', 'high humidity'),
    ],
  ),
  _Question(
    text: 'How much sun does your space get?',
    key: 'sun',
    options: [
      _Option('🌑', 'Barely any', 'no direct sun'),
      _Option('🌒', 'A little', 'bright but indirect'),
      _Option('🌞', 'Lots', 'south-facing window'),
      _Option('☀', 'Outdoor full sun', null),
    ],
  ),
  _Question(
    text: 'How committed are you to plant care?',
    key: 'commitment',
    options: [
      _Option('🦥', 'Forget it', 'water once a month'),
      _Option('🌱', 'Weekly', 'a little attention'),
      _Option('🧑‍🌾', 'Daily', 'I love caring for plants'),
      _Option('🏆', 'Expert', 'I know what I\'m doing'),
    ],
  ),
  _Question(
    text: 'Do you have pets?',
    key: 'pets',
    options: [
      _Option('🐱', 'Cat', null),
      _Option('🐶', 'Dog', null),
      _Option('🐈 🐕', 'Both', null),
      _Option('✗', 'None', null),
    ],
  ),
];

/// Variation A — one-question-per-screen card flow (recommended).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _step = 0;
  final _answers = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final q = _questions[_step];
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Find your plant')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Row(
              children: List.generate(_questions.length, (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  color: i <= _step ? AppColors.accent : Colors.grey.shade300,
                ),
              )),
            ),
            const SizedBox(height: 8),
            Text('Q ${_step + 1} of ${_questions.length}', style: tt.labelSmall),
            const SizedBox(height: 16),

            Text(q.text, style: tt.displayMedium?.copyWith(height: 1.15)),
            const SizedBox(height: 6),
            Text("Pick one that fits best 😊", style: tt.labelSmall),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: q.options.map((opt) {
                  final selected = _answers[q.key] == opt.label;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => setState(() => _answers[q.key] = opt.label),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected ? AppColors.accent : Theme.of(context).dividerColor,
                            width: selected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: selected ? AppColors.accentMuted : Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(
                          children: [
                            Text(opt.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opt.label, style: tt.bodyMedium),
                                  if (opt.subtitle != null)
                                    Text(opt.subtitle!, style: tt.labelSmall),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('← back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _answers[q.key] != null ? _next : null,
                    child: Text(_step == _questions.length - 1 ? 'See matches →' : 'next →'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    } else {
      context.push(AppRoutes.quizResults, extra: _answers);
    }
  }
}

class _Question {
  final String text;
  final String key;
  final List<_Option> options;
  const _Question({required this.text, required this.key, required this.options});
}

class _Option {
  final String icon;
  final String label;
  final String? subtitle;
  const _Option(this.icon, this.label, this.subtitle);
}
