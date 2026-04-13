import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/question.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/battery_nav_bar.dart';
import '../../widgets/question_card.dart';
import 'review_screen.dart';

/// A free-practice battery (topic or random).
/// Tracks answers, updates stats on finish, then opens review.
class PracticeBatteryScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final String? topicId;     // null = random (mixed topics)
  final String? topicName;

  const PracticeBatteryScreen({
    super.key,
    required this.title,
    required this.questions,
    this.topicId,
    this.topicName,
  });

  @override
  State<PracticeBatteryScreen> createState() => _PracticeBatteryScreenState();
}

class _PracticeBatteryScreenState extends State<PracticeBatteryScreen> {
  int _current = 0;
  final Map<int, String> _selected = {};   // index → answerId
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
      // Build per-topic stats delta
      final Map<String, _TopicDelta> deltas = {};
      for (int i = 0; i < widget.questions.length; i++) {
        final q = widget.questions[i];
        final tid = q.topicId;
        final tname = q.topicName;
        deltas.putIfAbsent(tid, () => _TopicDelta(tid, tname));
        deltas[tid]!.answered++;
        if (_selected[i] == q.correctAnswerId) deltas[tid]!.correct++;
      }
      final svc = ExamService();
      for (final d in deltas.values) {
        await svc.updateStatsForPractice(
          userId: uid,
          topicId: d.topicId,
          topicName: d.topicName,
          answered: d.answered,
          correct: d.correct,
        );
      }
    }

    if (mounted) {
      // Build review entries using public ReviewEntry
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
          builder: (_) => ReviewScreen(
            title: widget.title,
            entries: entries,
          ),
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
          // Progress indicator
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
                  // Topic label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.ocean.withOpacity(0.5)),
                    ),
                    child: Text(
                      q.topicName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Counter
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
            onPrevious: _current > 0
                ? () => setState(() => _current--)
                : null,
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

class _TopicDelta {
  final String topicId;
  final String topicName;
  int answered = 0;
  int correct = 0;
  _TopicDelta(this.topicId, this.topicName);
}
