import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/question_service.dart';
import '../../services/stats_service.dart';
import '../../theme/app_theme.dart';
import 'practice_battery_screen.dart';

class RandomBatteryScreen extends StatefulWidget {
  const RandomBatteryScreen({super.key});

  @override
  State<RandomBatteryScreen> createState() => _RandomBatteryScreenState();
}

class _RandomBatteryScreenState extends State<RandomBatteryScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final answeredIds = await StatsService().getAllAnsweredQuestionIds(uid);
      final questions = await QuestionService().getBatteryRandom(answeredIds);

      if (!mounted) return;
      if (questions.isEmpty) {
        setState(() { _loading = false; _error = 'No hay preguntas disponibles.'; });
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PracticeBatteryScreen(
            title: 'Preguntas aleatorias',
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas aleatorias')),
      body: Center(
        child: _error != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.incorrect)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        )
            : const CircularProgressIndicator(color: AppTheme.gold),
      ),
    );
  }
}
