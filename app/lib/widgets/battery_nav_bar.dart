import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BatteryNavBar extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onFinish;
  final VoidCallback? onNext;

  const BatteryNavBar({
    super.key,
    this.onPrevious,
    required this.onFinish,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.navyLight,
        border: Border(top: BorderSide(color: AppTheme.ocean.withOpacity(0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('ANTERIOR'),
                style: TextButton.styleFrom(
                  foregroundColor: onPrevious != null
                      ? AppTheme.onSurface
                      : AppTheme.onSurfaceSub,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.incorrect,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text('TERMINAR'),
                ),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onNext,
                icon: const Text('SIGUIENTE'),
                label: const Icon(Icons.chevron_right, size: 20),
                style: TextButton.styleFrom(
                  foregroundColor: onNext != null
                      ? AppTheme.onSurface
                      : AppTheme.onSurfaceSub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
