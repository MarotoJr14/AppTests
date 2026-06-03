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
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _examSvc = ExamService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'No autenticado.';
      });
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
      setState(() {
        _loading = false;
        _error = e.message;
      });
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.ocean.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.ocean.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Esta prueba tiene una duración de UNA HORA Y TREINTA MINUTOS.\n\n'
                    'Puedes introducir un nombre para el examen, y de esta forma podrás consultarlo, una vez finalizado, en tu progreso',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: AppTheme.onSurface),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Convocatoria junio 2025',
                    prefixIcon: Icon(Icons.drive_file_rename_outline,
                        color: AppTheme.onSurfaceSub),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Introduce un nombre para el examen'
                      : null,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.ocean.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.ocean.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.gold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Las preguntas se seleccionarán de una base de datos con más de 10.000 preguntas, elaboradas y revisadas por expertos de escuelas náuticas y se rigen por lo dispuesto en el R.D. 875/2014 de 10 de Octubre (BOE 247 del 11 de Octubre de 2014 de Ministerio de Fomento por el que se regulan las titulaciones náuticas para el gobierno de embarcaciones de recreo).',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.incorrect.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.incorrect.withValues(alpha: 0.4)),
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
                const SizedBox(height: 40),
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
      ),
    );
  }
}
