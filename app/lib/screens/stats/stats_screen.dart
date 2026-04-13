import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'exam_history_screen.dart';
import 'topic_stats_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatsCard(
              icon: Icons.history_edu_outlined,
              title: 'Revisar exámenes',
              subtitle: 'Consulta y revisa todos tus exámenes realizados',
              color: AppTheme.ocean,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExamHistoryScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _StatsCard(
              icon: Icons.pie_chart_outline_rounded,
              title: 'Preguntas por tema',
              subtitle: 'Porcentaje de aciertos por cada tema',
              color: AppTheme.gold,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopicStatsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StatsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppTheme.onSurfaceSub.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
