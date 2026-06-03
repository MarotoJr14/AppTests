import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/topic.dart';
import '../../services/question_service.dart';
import '../../services/stats_service.dart';
import '../../theme/app_theme.dart';
import '../question/practice_battery_screen.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

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

  static const _topicColors = <String, Color>{
    'nomenclatura_nautica':  Color(0xFF1A6B8A),
    'amarre_fondeo':         Color(0xFF2E7D32),
    'seguridad_mar':         Color(0xFFC62828),
    'legislacion':           Color(0xFF6A1B9A),
    'balizamiento':          Color(0xFF00695C),
    'reglamento_abordajes':  Color(0xFF1565C0),
    'maniobra_navegacion':   Color(0xFF0277BD),
    'emergencias_mar':       Color(0xFFBF360C),
    'meteorologia':          Color(0xFF4527A0),
    'teoria_navegacion':     Color(0xFF558B2F),
    'carta_navegacion':      Color(0xFF00796B),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas por tema')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: Topic.catalogue.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final entry = Topic.catalogue[i];
          final id    = entry['id'] as String;
          final name  = entry['name'] as String;
          final count = entry['examQuestionCount'] as int;
          final icon  = _topicIcons[id] ?? Icons.help_outline;
          final color = _topicColors[id] ?? AppTheme.ocean;

          return _TopicCard(id: id, name: name, count: count, icon: icon, color: color);
        },
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String id;
  final String name;
  final int count;
  final IconData icon;
  final Color color;

  const _TopicCard({
    required this.id,
    required this.name,
    required this.count,
    required this.icon,
    required this.color,
  });

  Future<void> _start(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
    );

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final userResults = await StatsService().getUserQuestionResults(uid);
      final answeredIds = userResults.keys.toSet();
      final questions = await QuestionService().getBatteryForTopic(
        id,
        answeredIds,
        userResults: userResults,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        if (questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay preguntas para este tema aún.')),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PracticeBatteryScreen(title: name, questions: questions),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _start(context),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('$count preguntas en el examen real',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.onSurfaceSub.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
