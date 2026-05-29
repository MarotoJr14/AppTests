import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/question.dart';
import '../../models/user_question_result.dart';
import '../../services/stats_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/battery_nav_bar.dart';
import '../../widgets/question_card.dart';
import 'review_screen.dart';

/// Free-practice battery (topic or random).
/// Loads ALL questions (unanswered first). No automatic end — only "Terminar".
/// On finish, saves the last answer per question to userQuestionResults.
class PracticeBatteryScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;

  const PracticeBatteryScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<PracticeBatteryScreen> createState() => _PracticeBatteryScreenState();
}

class _PracticeBatteryScreenState extends State<PracticeBatteryScreen> {
  int _current = 0;
  final Map<int, String> _selected = {};
  bool _finishing = false;

  Question get _q => widget.questions[_current];

  void _select(String answerId) {
    setState(() => _selected[_current] = answerId);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Build per-question result records (only for answered questions)
      final results = <UserQuestionResult>[];
      for (int i = 0; i < widget.questions.length; i++) {
        final selectedId = _selected[i];
        if (selectedId == null) continue; // skipped — don't save
        final q = widget.questions[i];
        results.add(UserQuestionResult(
          userId: uid,
          questionId: q.id,
          topicId: q.topicId,
          topicName: q.topicName,
          isCorrect: selectedId == q.correctAnswerId,
          answeredAt: DateTime.now(),
        ));
      }
      await StatsService().saveQuestionResults(results);
    }

    if (mounted) {
      final entries = List<ReviewEntry>.generate(
        widget.questions.length,
            (i) => ReviewEntry(
          statement: widget.questions[i].statement,
          answers: widget.questions[i].answers,
          correctAnswerId: widget.questions[i].correctAnswerId,
          selectedAnswerId: _selected[i],
          topicName: widget.questions[i].topicName,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReviewScreen(title: widget.title, entries: entries),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _q;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_current + 1) / widget.questions.length,
            backgroundColor: AppTheme.surfaceCard,
            valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.ocean.withOpacity(0.5)),
                    ),
                    child: Text(
                      q.topicName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pregunta ${_current + 1} / ${widget.questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  QuestionCard(
                    statement: q.statement,
                    answers: q.answers,
                    correctAnswerId: q.correctAnswerId,
                    selectedAnswerId: _selected[_current],
                    mode: QuestionMode.practice,
                    onAnswerSelected: _select,
                  ),
                ],
              ),
            ),
          ),
          BatteryNavBar(
            onPrevious: _current > 0 ? () => setState(() => _current--) : null,
            onFinish: _finishing ? null : _finish,
            onNext: _current < widget.questions.length - 1
                ? () => setState(() => _current++)
                : null,
          ),
        ],
      ),
    );
  }
}
