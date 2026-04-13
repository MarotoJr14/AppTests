import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/question.dart';
import '../../theme/app_theme.dart';

enum QuestionMode { practice, review }

class QuestionCard extends StatefulWidget {
  final String statement;
  final List<Answer> answers;          // fixed-order from Firestore
  final String correctAnswerId;
  final String? selectedAnswerId;
  final QuestionMode mode;
  final ValueChanged<String>? onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.statement,
    required this.answers,
    required this.correctAnswerId,
    this.selectedAnswerId,
    this.mode = QuestionMode.practice,
    this.onAnswerSelected,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late List<Answer> _shuffled;
  static const _labels = ['a', 'b', 'c', 'd'];

  @override
  void initState() {
    super.initState();
    _shuffled = List<Answer>.from(widget.answers)..shuffle(Random());
  }

  // Re-shuffle only when question changes (statement changes)
  @override
  void didUpdateWidget(QuestionCard old) {
    super.didUpdateWidget(old);
    if (old.statement != widget.statement) {
      _shuffled = List<Answer>.from(widget.answers)..shuffle(Random());
    }
  }

  Color _tileColor(String answerId) {
    if (widget.mode == QuestionMode.review) {
      if (answerId == widget.correctAnswerId) return AppTheme.correct.withOpacity(0.25);
      if (answerId == widget.selectedAnswerId) return AppTheme.incorrect.withOpacity(0.25);
      return Colors.transparent;
    }
    if (answerId == widget.selectedAnswerId) {
      return AppTheme.selected.withOpacity(0.25);
    }
    return Colors.transparent;
  }

  Color _tileBorder(String answerId) {
    if (widget.mode == QuestionMode.review) {
      if (answerId == widget.correctAnswerId) return AppTheme.correct;
      if (answerId == widget.selectedAnswerId) return AppTheme.incorrect;
      return AppTheme.ocean.withOpacity(0.3);
    }
    if (answerId == widget.selectedAnswerId) return AppTheme.selected;
    return AppTheme.ocean.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Statement ────────────────────────────────────────────────
            Text(widget.statement,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ── Answers ─────────────────────────────────────────────────
            ...List.generate(_shuffled.length, (i) {
              final answer = _shuffled[i];
              final label = _labels[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _tileColor(answer.id),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _tileBorder(answer.id)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: widget.mode == QuestionMode.practice
                          ? () => widget.onAnswerSelected?.call(answer.id)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              '$label)',
                              style: TextStyle(
                                color: _tileColor(answer.id) ==
                                        Colors.transparent
                                    ? AppTheme.onSurfaceSub
                                    : AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                answer.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: _tileBorder(answer.id) ==
                                              AppTheme.ocean.withOpacity(0.3)
                                          ? AppTheme.onSurface
                                          : AppTheme.onSurface,
                                    ),
                              ),
                            ),
                            if (widget.mode == QuestionMode.review) ...[
                              const SizedBox(width: 8),
                              if (answer.id == widget.correctAnswerId)
                                const Icon(Icons.check_circle,
                                    color: AppTheme.correct, size: 18)
                              else if (answer.id == widget.selectedAnswerId)
                                const Icon(Icons.cancel,
                                    color: AppTheme.incorrect, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
