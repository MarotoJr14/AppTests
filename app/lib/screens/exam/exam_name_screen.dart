import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';
import 'exam_battery_screen.dart';

class ExamNameScreen extends StatefulWidget {
  const ExamNameScreen({super.key});

  @override
  State<ExamNameScreen> createState() => _ExamNameScreenState();
}

class _ExamNameScreenState extends State<ExamNameScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _examSvc   = ExamService();
  bool _loading    = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() { _loading = false; _error = 'No autenticado.'; });
      return;
    }

    try {
      final exam = await _examSvc.createExam(uid, _nameCtrl.text.trim());
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ExamBatteryScreen(exam: exam),
          ),
        );
      }
    } on ExamException catch (e) {
      setState(() { _loading = false; _error = e.message; });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error al crear el examen. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulación de examen real')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.ocean.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.ocean.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.gold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '45 preguntas distribuidas por tema, igual que el examen oficial de Patrón de Recreo.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Text('Nombre del examen',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Asigna un nombre para identificar este examen en tus estadísticas.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del examen',
                  hintText: 'Ej: Convocatoria junio 2025',
                  prefixIcon: Icon(Icons.drive_file_rename_outline,
                      color: AppTheme.onSurfaceSub),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Introduce un nombre para el examen'
                    : null,
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.incorrect.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.incorrect.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.incorrect, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppTheme.incorrect, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _start,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: AppTheme.navy, strokeWidth: 2),
                        )
                      : const Text('COMENZAR EXAMEN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
