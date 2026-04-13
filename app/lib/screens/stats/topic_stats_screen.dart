import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/topic.dart';
import '../../models/user_topic_stats.dart';
import '../../services/stats_service.dart';
import '../../theme/app_theme.dart';

class TopicStatsScreen extends StatefulWidget {
  const TopicStatsScreen({super.key});

  @override
  State<TopicStatsScreen> createState() => _TopicStatsScreenState();
}

class _TopicStatsScreenState extends State<TopicStatsScreen> {
  late Future<List<UserTopicStats>> _future;

  static const _topicIcons = <String, IconData>{
    'nomenclatura_nautica':  Icons.directions_boat_outlined,
    'amarre_fondeo':         Icons.anchor,
    'seguridad_mar':         Icons.health_and_safety_outlined,
    'legislacion':           Icons.gavel_outlined,
    'balizamiento':          Icons.navigation_outlined,
    'reglamento_abordajes':  Icons.compare_arrows_outlined,
    'maniobra_navegacion':   Icons.explore_outlined,
    'emergencias_mar':       Icons.sos_outlined,
    'meteorologia':          Icons.cloud_outlined,
    'teoria_navegacion':     Icons.map_outlined,
    'carta_navegacion':      Icons.map,
  };

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _future = StatsService().getUserTopicStats(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas por tema')),
      body: FutureBuilder<List<UserTopicStats>>(
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
          final stats = snap.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final s = stats[i];
              final icon = _topicIcons[s.topicId] ?? Icons.help_outline;
              return _TopicStatCard(stats: s, icon: icon);
            },
          );
        },
      ),
    );
  }
}

class _TopicStatCard extends StatelessWidget {
  final UserTopicStats stats;
  final IconData icon;

  const _TopicStatCard({required this.stats, required this.icon});

  @override
  Widget build(BuildContext context) {
    final rate    = stats.correctRate;
    final pct     = (rate * 100).round();
    final hasData = stats.totalAnswered > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.ocean.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.ocean.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.oceanLight, size: 24),
          ),
          const SizedBox(width: 14),

          // Name + counters
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stats.topicName,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  hasData
                      ? '${stats.totalCorrect} / ${stats.totalAnswered} correctas'
                      : 'Sin datos aún',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Pie chart
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 20,
                    sections: hasData
                        ? [
                            PieChartSectionData(
                              value: rate,
                              color: _rateColor(rate),
                              radius: 12,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 1 - rate,
                              color: AppTheme.navy,
                              radius: 12,
                              showTitle: false,
                            ),
                          ]
                        : [
                            PieChartSectionData(
                              value: 1,
                              color: AppTheme.ocean.withOpacity(0.2),
                              radius: 12,
                              showTitle: false,
                            ),
                          ],
                  ),
                ),
                Text(
                  hasData ? '$pct%' : '--',
                  style: TextStyle(
                    color: hasData ? _rateColor(rate) : AppTheme.onSurfaceSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _rateColor(double rate) {
    if (rate >= 0.8) return AppTheme.correct;
    if (rate >= 0.5) return AppTheme.gold;
    return AppTheme.incorrect;
  }
}
