import 'package:flutter/material.dart';
import '../../models/exam.dart';
import '../../theme/app_theme.dart';
import '../../widgets/question_card.dart';

class ExamReviewScreen extends StatefulWidget {
  final Exam exam;
  const ExamReviewScreen({super.key, required this.exam});

  @override
  State<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends State<ExamReviewScreen> {
  bool _dialogShown = false;

  int get _correct => widget.exam.correctCount ??
      widget.exam.allQuestions
          .where((q) => q.isCorrect == true)
          .length;

  int get _total => widget.exam.totalQuestions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
  }

  void _showResult() {
    if (_dialogShown) return;
    _dialogShown = true;
    final pct = (_correct / _total * 100).round();
    final passed = _correct >= 38; // 38/45 to pass

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(widget.exam.name,
            style: Theme.of(context).textTheme.displayMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.flag_rounded,
              size: 52,
              color: passed ? AppTheme.gold : AppTheme.onSurfaceSub,
            ),
            const SizedBox(height: 16),
            Text(
              'Has acertado $_correct preguntas de un total de $_total.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$pct%  —  ${passed ? "APROBADO 🎉" : "NO APROBADO"}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: passed ? AppTheme.correct : AppTheme.incorrect,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('REVISAR EXAMEN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.exam.sections;

    return Scaffold(
      appBar: AppBar(
        title: Text('Revisión — ${widget.exam.name}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Pop back to Home (remove all routes above it)
            Navigator.of(context)
                .popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (_, si) {
          final section = sections[si];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.topicName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: AppTheme.gold),
                      ),
                    ),
                    Text(
                      '${section.questions.where((q) => q.isCorrect == true).length}/${section.questions.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Questions
              ...List.generate(section.questions.length, (qi) {
                final q = section.questions[qi];
                final isCorrect = q.isCorrect == true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Pregunta ${qi + 1}/${section.questions.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect
                                ? AppTheme.correct
                                : AppTheme.incorrect,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      QuestionCard(
                        key: ValueKey('$si-$qi'),
                        statement: q.statement,
                        answers: q.answers,
                        correctAnswerId: q.correctAnswerId,
                        selectedAnswerId: q.selectedAnswerId,
                        mode: QuestionMode.review,
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
