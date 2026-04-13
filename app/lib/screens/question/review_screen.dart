import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../theme/app_theme.dart';
import '../../widgets/question_card.dart';

/// Public entry used by any screen that wants to open a ReviewScreen.
class ReviewEntry {
  final String statement;
  final List<Answer> answers;
  final String correctAnswerId;
  final String? selectedAnswerId;
  final String topicName;

  const ReviewEntry({
    required this.statement,
    required this.answers,
    required this.correctAnswerId,
    this.selectedAnswerId,
    required this.topicName,
  });

  factory ReviewEntry.fromQuestion(Question q, String? selectedAnswerId) =>
      ReviewEntry(
        statement: q.statement,
        answers: q.answers,
        correctAnswerId: q.correctAnswerId,
        selectedAnswerId: selectedAnswerId,
        topicName: q.topicName,
      );
}

class ReviewScreen extends StatefulWidget {
  final String title;
  final List<ReviewEntry> entries;

  const ReviewScreen({
    super.key,
    required this.title,
    required this.entries,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _dialogShown = false;

  int get _correct => widget.entries
      .where((e) => e.selectedAnswerId != null &&
          e.selectedAnswerId == e.correctAnswerId)
      .length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
  }

  void _showDialog() {
    if (_dialogShown) return;
    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Resultado',
            style: Theme.of(context).textTheme.displayMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_rounded, size: 48, color: AppTheme.gold),
            const SizedBox(height: 16),
            Text(
              'Has acertado $_correct preguntas de un total de ${widget.entries.length}.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ACEPTAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revisión — ${widget.title}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final e = widget.entries[i];
          final isCorrect = e.selectedAnswerId == e.correctAnswerId;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(e.topicName,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? AppTheme.correct : AppTheme.incorrect,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              QuestionCard(
                statement: e.statement,
                answers: e.answers,
                correctAnswerId: e.correctAnswerId,
                selectedAnswerId: e.selectedAnswerId,
                mode: QuestionMode.review,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Factory helper ────────────────────────────────────────────────────────
// ignore: avoid_classes_with_only_static_members
class ReviewScreenFactory {
  static ReviewScreen fromQuestions({
    required String title,
    required List<Question> questions,
    required Map<int, String> selected,
  }) {
    return ReviewScreen(
      title: title,
      entries: List.generate(
        questions.length,
        (i) => ReviewEntry(
          statement: questions[i].statement,
          answers: questions[i].answers,
          correctAnswerId: questions[i].correctAnswerId,
          selectedAnswerId: selected[i],
          topicName: questions[i].topicName,
        ),
      ),
    );
  }
}
