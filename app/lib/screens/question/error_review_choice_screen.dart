import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/question.dart';
import '../../models/topic.dart';
import '../../models/user_question_result.dart';
import '../../services/question_service.dart';
import '../../services/stats_service.dart';
import '../../theme/app_theme.dart';
import 'practice_battery_screen.dart';
import 'review_screen.dart';

class ErrorReviewChoiceScreen extends StatelessWidget {
  const ErrorReviewChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repaso de errores')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OptionCard(
              icon: Icons.menu_book_outlined,
              title: 'Por tema',
              subtitle: 'Repasar los errores de un tema concreto',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ErrorReviewTopicSelectionScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.public,
              title: 'General',
              subtitle: 'Repasar todos los errores de todos los temas',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ErrorReviewAllErrorsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.ocean.withOpacity(0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.gold, size: 28),
                ),
                const SizedBox(height: 18),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorReviewTopicSelectionScreen extends StatelessWidget {
  const ErrorReviewTopicSelectionScreen({super.key});

  Future<Map<String, int>> _fetchErrorCounts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final results = await StatsService().getWrongQuestionResults(uid);
    final counts = <String, int>{};
    for (final result in results) {
      counts[result.topicId] = (counts[result.topicId] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Errores por tema')),
      body: FutureBuilder<Map<String, int>>(
        future: _fetchErrorCounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.incorrect)),
            );
          }
          final counts = snapshot.data ?? {};
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: Topic.catalogue.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final topic = Topic.catalogue[index];
              final errors = counts[topic['id'] as String] ?? 0;
              return _TopicErrorCard(
                title: topic['name'] as String,
                subtitle: errors > 0 ? '$errors preguntas con errores' : 'Sin errores por ahora',
                enabled: errors > 0,
                onTap: errors > 0
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ErrorReviewTopicErrorsScreen(
                              topicId: topic['id'] as String,
                              topicName: topic['name'] as String,
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _TopicErrorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const _TopicErrorCard({
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled ? AppTheme.ocean.withOpacity(0.4) : AppTheme.onSurfaceSub.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(
                  enabled ? Icons.chevron_right : Icons.lock_outline,
                  color: enabled ? AppTheme.gold : AppTheme.onSurfaceSub,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionWithResult {
  final Question question;
  final UserQuestionResult result;

  _QuestionWithResult({
    required this.question,
    required this.result,
  });
}

class ErrorReviewTopicErrorsScreen extends StatelessWidget {
  final String topicId;
  final String topicName;

  const ErrorReviewTopicErrorsScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  Future<List<_QuestionWithResult>> _loadErrors() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final wrongResults = await StatsService().getWrongQuestionResultsByTopic(uid, topicId);
    final resultMap = {for (var r in wrongResults) r.questionId: r};
    final questions = await QuestionService().getQuestionsByTopic(topicId);
    return questions
        .where((q) => resultMap.containsKey(q.id))
        .map((q) => _QuestionWithResult(question: q, result: resultMap[q.id]!))
        .toList();
  }

  void _reviewQuestions(BuildContext context, List<_QuestionWithResult> items) {
    if (items.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeBatteryScreen(
          title: 'Repaso de errores — $topicName',
          questions: items.map((item) => item.question).toList(),
        ),
      ),
    );
  }

  void _reviewSingle(BuildContext context, _QuestionWithResult item) {
    final entry = ReviewEntry(
      statement: item.question.statement,
      answers: item.question.answers,
      correctAnswerId: item.question.correctAnswerId,
      selectedAnswerId: item.result.selectedAnswerId,
      topicName: item.question.topicName,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          title: 'Revisión — ${item.question.topicName}',
          entries: [entry],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Errores — $topicName')),
      body: FutureBuilder<List<_QuestionWithResult>>(
        future: _loadErrors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.incorrect)),
            );
          }
          final items = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: items.isNotEmpty ? () => _reviewQuestions(context, items) : null,
                  child: const Text('Repasar'),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No tienes errores registrados en este tema.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _QuestionErrorCard(
                          statement: item.question.statement,
                          topicName: item.question.topicName,
                          onTap: () => _reviewSingle(context, item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ErrorReviewAllErrorsScreen extends StatelessWidget {
  const ErrorReviewAllErrorsScreen({super.key});

  Future<List<_QuestionWithResult>> _loadErrors() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final wrongResults = await StatsService().getWrongQuestionResults(uid);
    final resultMap = {for (var r in wrongResults) r.questionId: r};
    final questions = await QuestionService().getAllQuestions();
    return questions
        .where((q) => resultMap.containsKey(q.id))
        .map((q) => _QuestionWithResult(question: q, result: resultMap[q.id]!))
        .toList();
  }

  void _reviewQuestions(BuildContext context, List<_QuestionWithResult> items) {
    if (items.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeBatteryScreen(
          title: 'Repaso de errores general',
          questions: items.map((item) => item.question).toList(),
        ),
      ),
    );
  }

  void _reviewSingle(BuildContext context, _QuestionWithResult item) {
    final entry = ReviewEntry(
      statement: item.question.statement,
      answers: item.question.answers,
      correctAnswerId: item.question.correctAnswerId,
      selectedAnswerId: item.result.selectedAnswerId,
      topicName: item.question.topicName,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          title: 'Revisión — ${item.question.topicName}',
          entries: [entry],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Errores generales')),
      body: FutureBuilder<List<_QuestionWithResult>>(
        future: _loadErrors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.incorrect)),
            );
          }
          final items = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: items.isNotEmpty ? () => _reviewQuestions(context, items) : null,
                  child: const Text('Repasar'),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No tienes errores registrados.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _QuestionErrorCard(
                          statement: item.question.statement,
                          topicName: item.question.topicName,
                          onTap: () => _reviewSingle(context, item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuestionErrorCard extends StatelessWidget {
  final String statement;
  final String topicName;
  final VoidCallback onTap;

  const _QuestionErrorCard({
    required this.statement,
    required this.topicName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.ocean.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(topicName, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.onSurfaceSub),
                  ],
                ),
                const SizedBox(height: 12),
                Text(statement, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
