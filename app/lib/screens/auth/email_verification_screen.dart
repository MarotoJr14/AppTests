import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _sending = false;
  bool _checking = false;
  String? _message;

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _sendVerificationEmail() async {
    if (_user == null) return;
    setState(() {
      _sending = true;
      _message = null;
    });

    try {
      await _authService.sendEmailVerification(_user!);
      setState(() {
        _message = 'Se ha enviado un correo de verificación a ${_user!.email}.';
      });
    } catch (_) {
      setState(() {
        _message = 'No se pudo enviar el correo. Intenta de nuevo más tarde.';
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_user == null) return;
    setState(() {
      _checking = true;
      _message = null;
    });

    try {
      await _user!.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        return;
      }
      setState(() {
        _message = 'Tu correo no está verificado aún. Revisa tu bandeja y confirma el enlace.';
      });
    } catch (_) {
      setState(() {
        _message = 'No se pudo comprobar el estado. Inténtalo de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de correo'),
        backgroundColor: AppTheme.navy,
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, size: 88, color: AppTheme.gold),
                  const SizedBox(height: 24),
                  Text(
                    'Verifica tu correo electrónico',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Te hemos enviado un email de verificación. Confirma tu dirección para poder acceder a la app.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceSub),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (_user?.email != null) ...[
                    Text(
                      _user!.email!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.gold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_message != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.onSurface.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _message!,
                        style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _sendVerificationEmail,
                      child: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: AppTheme.navy, strokeWidth: 2),
                            )
                          : const Text('REENVIAR CORREO'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _checking ? null : _checkVerificationStatus,
                      child: _checking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
                            )
                          : const Text('YA HE VERIFICADO MI CORREO'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(color: AppTheme.gold.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
