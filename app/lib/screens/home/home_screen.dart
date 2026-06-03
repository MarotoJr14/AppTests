import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../exam/exam_name_screen.dart';
import '../question/error_review_choice_screen.dart';
import '../question/random_battery_screen.dart';
import '../topic/topic_list_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.navy, AppTheme.navyLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.onSurfaceSub),
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Logo + title
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/blue_sailing_icon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Blue Sailing Tests',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Patrón de Embarcaciones de Recreo',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.gold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 32),

              // Cards grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 14.0;
                      final cardWidth = (constraints.maxWidth - spacing) / 2;
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              height: 160,
                              child: _HomeCard(
                                icon: Icons.assignment_outlined,
                                title: 'Simulación de\nexamen real',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ExamNameScreen()),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              height: 160,
                              child: _HomeCard(
                                icon: Icons.shuffle_rounded,
                                title: 'Preguntas\naleatorias',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RandomBatteryScreen()),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              height: 160,
                              child: _HomeCard(
                                icon: Icons.menu_book_outlined,
                                title: 'Preguntas\npor tema',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TopicListScreen()),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              height: 160,
                              child: _HomeCard(
                                icon: Icons.error_outline,
                                title: 'Repaso de\nerrores',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ErrorReviewChoiceScreen()),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth,
                              height: 160,
                              child: _HomeCard(
                                icon: Icons.bar_chart_rounded,
                                title: 'Estadísticas\ny progreso',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
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
            border: Border.all(color: AppTheme.ocean.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.gold, size: 28),
                ),
                const Spacer(),
                Text(title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
