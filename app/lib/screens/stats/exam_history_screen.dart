import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/exam.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';
import '../exam/exam_review_screen.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  late Future<List<Exam>> _future;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _future = ExamService().getUserExams(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de exámenes')),
      body: FutureBuilder<List<Exam>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.gold));
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: AppTheme.incorrect)),
            );
          }
          final exams = snap.data ?? [];
          if (exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 64, color: AppTheme.onSurfaceSub),
                  const SizedBox(height: 16),
                  Text('Todavía no has realizado ningún examen.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ExamTile(exam: exams[i]),
          );
        },
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final Exam exam;
  const _ExamTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    final correct = exam.correctCount ?? 0;
    final total   = exam.totalQuestions;
    final pct     = (correct / total * 100).round();
    final passed  = correct >= 38;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ExamReviewScreen(exam: exam)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: passed
                    ? AppTheme.correct.withOpacity(0.3)
                    : AppTheme.ocean.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(exam.completedAt ?? exam.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$correct/$total',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color:
                        passed ? AppTheme.correct : AppTheme.incorrect,
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    color: AppTheme.onSurfaceSub.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
