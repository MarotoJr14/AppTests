import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/exam.dart';
import '../../models/question.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/battery_nav_bar.dart';
import '../../widgets/question_card.dart';
import 'exam_review_screen.dart';

class ExamBatteryScreen extends StatefulWidget {
  final Exam exam;
  const ExamBatteryScreen({super.key, required this.exam});

  @override
  State<ExamBatteryScreen> createState() => _ExamBatteryScreenState();
}

class _ExamBatteryScreenState extends State<ExamBatteryScreen> {
  late Exam _exam;
  // Flat index across all questions
  int _globalIndex = 0;
  bool _finishing = false;
  final Map<int, List<Answer>> _answerOrders = {};
  final Random _rng = Random();
  Timer? _timer;
  late Duration _remainingTime;

  static const Duration _examDuration = Duration(minutes: 90);

  // Pre-computed flat list for navigation
  late final List<_FlatEntry> _flat;

  @override
  void initState() {
    super.initState();
    _exam = widget.exam;
    _flat = _buildFlat(_exam);
    _remainingTime = _calculateRemainingTime();
    if (_remainingTime == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishByTimeout());
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calculateRemainingTime() {
    final endsAt = _exam.createdAt.add(_examDuration);
    final remaining = endsAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _tick() {
    final remaining = _calculateRemainingTime();
    if (!mounted) return;

    if (remaining == Duration.zero) {
      setState(() => _remainingTime = Duration.zero);
      _finishByTimeout();
      return;
    }

    setState(() => _remainingTime = remaining);
  }

  String _formatRemainingTime() {
    final hours = _remainingTime.inHours;
    final minutes =
        _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static List<_FlatEntry> _buildFlat(Exam exam) {
    final list = <_FlatEntry>[];
    for (int si = 0; si < exam.sections.length; si++) {
      final section = exam.sections[si];
      for (int qi = 0; qi < section.questions.length; qi++) {
        list.add(_FlatEntry(
          sectionIndex: si,
          questionIndex: qi,
          topicName: section.topicName,
          sectionTotal: section.questions.length,
        ));
      }
    }
    return list;
  }

  _FlatEntry get _current => _flat[_globalIndex];

  ExamQuestionEntry get _currentQuestion =>
      _exam.sections[_current.sectionIndex].questions[_current.questionIndex];

  bool get _hasUnansweredQuestions =>
      _exam.allQuestions.any((q) => q.selectedAnswerId == null);

  List<Answer> _answersFor(int globalIndex) {
    return _answerOrders.putIfAbsent(
      globalIndex,
      () {
        final entry = _flat[globalIndex];
        final q =
            _exam.sections[entry.sectionIndex].questions[entry.questionIndex];
        return List<Answer>.from(q.answers)..shuffle(_rng);
      },
    );
  }

  void _applyDisplayedAnswerOrders() {
    for (int i = 0; i < _flat.length; i++) {
      final entry = _flat[i];
      final q =
          _exam.sections[entry.sectionIndex].questions[entry.questionIndex];
      q.answers
        ..clear()
        ..addAll(_answersFor(i));
    }
  }

  void _select(String answerId) {
    if (_finishing || _remainingTime == Duration.zero) return;
    setState(() {
      final q = _exam
          .sections[_current.sectionIndex].questions[_current.questionIndex];
      q.selectedAnswerId = answerId;
      q.isCorrect = answerId == q.correctAnswerId;
    });
  }

  Future<void> _completeExam({required bool timedOut}) async {
    if (_finishing) return;
    _timer?.cancel();
    setState(() => _finishing = true);
    _applyDisplayedAnswerOrders();

    try {
      await ExamService().completeExam(_exam);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
      if (mounted) {
        setState(() => _finishing = false);
      }
      if (!timedOut && mounted && _remainingTime > Duration.zero) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
      return;
    }

    if (mounted) {
      if (timedOut) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Tiempo agotado. El examen se ha finalizado automáticamente.'),
          ),
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExamReviewScreen(exam: _exam),
        ),
      );
    }
  }

  Future<void> _finishByTimeout() async {
    if (_finishing || !mounted) return;
    await _completeExam(timedOut: true);
  }

  Future<void> _finish() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('¿Terminar examen?'),
        content: Text(
          _hasUnansweredQuestions
              ? 'Tienes preguntas sin responder. Estas preguntas se contarán como incorrectas.'
              : 'Has respondido todas las preguntas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR',
                style: TextStyle(color: AppTheme.onSurfaceSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('TERMINAR'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await _completeExam(timedOut: false);
  }

  @override
  Widget build(BuildContext context) {
    final entry = _current;
    final q = _currentQuestion;
    // Position of this question within its section (1-based)
    final sectionPos = entry.questionIndex + 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_finishing) {
          _finish();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simulación de examen real'),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _formatRemainingTime(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _remainingTime.inMinutes < 10
                            ? AppTheme.incorrect
                            : AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_globalIndex + 1} / ${_flat.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.gold),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Overall progress bar
            LinearProgressIndicator(
              value: (_globalIndex + 1) / _flat.length,
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
                        color: AppTheme.ocean.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.ocean.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        entry.topicName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.onSurface),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Section counter (only in real exam)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Pregunta $sectionPos/${entry.sectionTotal}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuestionCard(
                      key: ValueKey('$_globalIndex'),
                      statement: q.statement,
                      answers: _answersFor(_globalIndex),
                      correctAnswerId: q.correctAnswerId,
                      selectedAnswerId: q.selectedAnswerId,
                      mode: QuestionMode.practice,
                      onAnswerSelected: _select,
                    ),
                  ],
                ),
              ),
            ),
            BatteryNavBar(
              onPrevious: _globalIndex > 0
                  ? () => setState(() => _globalIndex--)
                  : null,
              onFinish: _finishing ? null : _finish,
              onNext: _globalIndex < _flat.length - 1
                  ? () => setState(() => _globalIndex++)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlatEntry {
  final int sectionIndex;
  final int questionIndex;
  final String topicName;
  final int sectionTotal;

  const _FlatEntry({
    required this.sectionIndex,
    required this.questionIndex,
    required this.topicName,
    required this.sectionTotal,
  });
}
