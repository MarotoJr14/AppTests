import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await _authService.registerWithCode(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        code: _codeCtrl.text,
      );
      await _authService.createUserProfile(cred.user!);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapAuthError(e.code));
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Error inesperado. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(String code) => switch (code) {
        'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
        'invalid-email' => 'Correo electrónico no válido.',
        'weak-password' => 'La contraseña es demasiado débil.',
        'too-many-requests' => 'Demasiados intentos. Espera un momento.',
        _ => 'Error al crear la cuenta. Inténtalo de nuevo.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.navy, AppTheme.navyLight, AppTheme.navy],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/blue_sailing_icon.png',
                      width: 96,
                      height: 96,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Registro',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Introduce tu correo, contraseña y el código de la empresa',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.gold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline, color: AppTheme.onSurfaceSub),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce tu correo' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppTheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.onSurfaceSub),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppTheme.onSurfaceSub,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Introduce una contraseña' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: AppTheme.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        prefixIcon: Icon(Icons.confirmation_number_outlined, color: AppTheme.onSurfaceSub),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce tu código' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.incorrect.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.incorrect.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.incorrect, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: AppTheme.incorrect, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.navy,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('CREAR CUENTA'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      child: Text(
                        'Volver al login',
                        style: TextStyle(color: AppTheme.gold.withOpacity(0.8), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

