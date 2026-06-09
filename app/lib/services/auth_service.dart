import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  static const String _registrationCodesCollection = 'registrationCodes';
  static const String _registrationLocksCollection = 'registrationLocks';
  static const Duration _codeReservationTtl = Duration(minutes: 10);
  static const Duration _lockDuration = Duration(minutes: 5);
  static const int _maxCodeAttempts = 3;
  static const Duration _codeReuseAfter = Duration(days: 365);

  Future<UserCredential> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (!cred.user!.emailVerified) {
      await _auth.signOut();
      throw const AuthException('Tu correo no está verificado. Revisa tu bandeja y confirma tu email.');
    }

    return cred;
  }

  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  /// Registro con código de empresa (en Firestore).
  ///
  /// Reglas:
  /// - 3 intentos para introducir un código válido (el error de email ya usado NO cuenta).
  /// - Tras 3 intentos fallidos de código, el correo queda bloqueado 5 minutos.
  /// - Los códigos se reactivan tras 1 año desde `usedAt` (reset automático al consultarlos).
  Future<UserCredential> registerWithCode({
    required String email,
    required String password,
    required String code,
  }) async {
    final emailNorm = email.trim().toLowerCase();
    final codeNorm = code.trim().toUpperCase();

    if (emailNorm.isEmpty || password.isEmpty || codeNorm.isEmpty) {
      throw const AuthException('Debes completar correo, contraseña y código.');
    }

    // NOTA: Se eliminó la comprobación con `fetchSignInMethodsForEmail()` porque está deprecada
    // y puede permitir enumeración de correos. Confiamos en que `createUserWithEmailAndPassword`
    // lanzará `email-already-in-use` si aplica (no se cuenta como intento de código).

    await _reserveRegistrationCode(emailNorm: emailNorm, codeNorm: codeNorm);

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailNorm,
        password: password,
      );
      await _finalizeRegistrationCode(emailNorm: emailNorm, codeNorm: codeNorm);
      await cred.user!.sendEmailVerification();
      return cred;
    } on FirebaseAuthException {
      await _releaseRegistrationCodeReservation(emailNorm: emailNorm, codeNorm: codeNorm);
      rethrow;
    } catch (_) {
      await _releaseRegistrationCodeReservation(emailNorm: emailNorm, codeNorm: codeNorm);
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final emailNorm = email.trim().toLowerCase();
    if (emailNorm.isEmpty) {
      throw const AuthException('Introduce tu correo electrónico.');
    }

    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
    if (!emailRegex.hasMatch(emailNorm)) {
      throw const AuthException('Correo electrónico no válido.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailNorm);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw const AuthException('Correo electrónico no válido.');
        case 'user-not-found':
          throw const AuthException('No existe ningún usuario con ese correo electrónico.');
        case 'too-many-requests':
          throw const AuthException('Demasiados intentos. Espera un momento e inténtalo de nuevo.');
        case 'network-request-failed':
          throw const AuthException('Error de conexión. Comprueba tu red e inténtalo de nuevo.');
        default:
          rethrow;
      }
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> createUserProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': user.email?.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _reserveRegistrationCode({
    required String emailNorm,
    required String codeNorm,
  }) async {
    final lockRef = _db.collection(_registrationLocksCollection).doc(emailNorm);
    final codeRef = _db.collection(_registrationCodesCollection).doc(codeNorm);
    final now = DateTime.now();

    try {
      await _db.runTransaction((tx) async {
        final lockSnap = await tx.get(lockRef);
        final lockedUntil = lockSnap.exists ? (lockSnap.data()?['lockedUntil'] as Timestamp?) : null;
        var failedAttempts = lockSnap.exists ? (lockSnap.data()?['failedCodeAttempts'] as int? ?? 0) : 0;

        if (lockedUntil != null) {
          final until = lockedUntil.toDate();
          if (until.isAfter(now)) {
            throw AuthException(_lockedMessage(until));
          }
          failedAttempts = 0;
          tx.set(
            lockRef,
            {
              'email': emailNorm,
              'failedCodeAttempts': 0,
              'lockedUntil': null,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }

        final codeSnap = await tx.get(codeRef);
        if (!codeSnap.exists) {
          _applyFailedCodeAttempt(
            tx: tx,
            lockRef: lockRef,
            emailNorm: emailNorm,
            now: now,
            currentAttempts: failedAttempts,
          );
          throw const AuthException('Código no válido o no disponible.');
        }

        final data = codeSnap.data()!;
        final available = data['available'] == true;
        final assignedEmail = (data['assignedEmail'] as String?)?.toLowerCase();
        final usedAtTs = data['usedAt'] as Timestamp?;
        final reservedForEmail = (data['reservedForEmail'] as String?)?.toLowerCase();
        final reservedUntilTs = data['reservedUntil'] as Timestamp?;

        if (!available && usedAtTs != null) {
          final usedAt = usedAtTs.toDate();
          if (usedAt.isBefore(now.subtract(_codeReuseAfter))) {
            tx.update(codeRef, {
              'available': true,
              'assignedEmail': null,
              'usedAt': null,
              'reservedForEmail': null,
              'reservedUntil': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        if (data['available'] != true) {
          _applyFailedCodeAttempt(
            tx: tx,
            lockRef: lockRef,
            emailNorm: emailNorm,
            now: now,
            currentAttempts: failedAttempts,
          );
          throw const AuthException('Código no válido o no disponible.');
        }

        if (assignedEmail == null || assignedEmail != emailNorm) {
          _applyFailedCodeAttempt(
            tx: tx,
            lockRef: lockRef,
            emailNorm: emailNorm,
            now: now,
            currentAttempts: failedAttempts,
          );
          throw const AuthException('Este código no está asignado a tu correo.');
        }

        if (reservedUntilTs != null) {
          final reservedUntil = reservedUntilTs.toDate();
          if (reservedUntil.isAfter(now) && reservedForEmail != null && reservedForEmail != emailNorm) {
            _applyFailedCodeAttempt(
              tx: tx,
              lockRef: lockRef,
              emailNorm: emailNorm,
              now: now,
              currentAttempts: failedAttempts,
            );
            throw const AuthException('Código no válido o no disponible.');
          }
        }

        tx.update(codeRef, {
          'reservedForEmail': emailNorm,
          'reservedUntil': Timestamp.fromDate(now.add(_codeReservationTtl)),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('No se pudo validar el código. Inténtalo de nuevo.');
    }
  }

  Future<void> _finalizeRegistrationCode({
    required String emailNorm,
    required String codeNorm,
  }) async {
    final lockRef = _db.collection(_registrationLocksCollection).doc(emailNorm);
    final codeRef = _db.collection(_registrationCodesCollection).doc(codeNorm);
    final now = DateTime.now();

    try {
      await _db.runTransaction((tx) async {
        final codeSnap = await tx.get(codeRef);
        if (!codeSnap.exists) {
          throw const AuthException('Código no válido o no disponible.');
        }

        final data = codeSnap.data()!;
        final available = data['available'] == true;
        final assignedEmail = (data['assignedEmail'] as String?)?.toLowerCase();
        final reservedForEmail = (data['reservedForEmail'] as String?)?.toLowerCase();
        final reservedUntilTs = data['reservedUntil'] as Timestamp?;
        final reservedUntil = reservedUntilTs?.toDate();

        if (!available || assignedEmail != emailNorm) {
          throw const AuthException('Código no válido o no disponible.');
        }
        if (reservedForEmail != emailNorm || reservedUntil == null || reservedUntil.isBefore(now)) {
          throw const AuthException('La validación del código ha caducado. Vuelve a intentarlo.');
        }

        tx.update(codeRef, {
          'available': false,
          'usedAt': Timestamp.fromDate(now),
          'reservedForEmail': null,
          'reservedUntil': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          lockRef,
          {
            'email': emailNorm,
            'failedCodeAttempts': 0,
            'lockedUntil': null,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('No se pudo finalizar el registro. Inténtalo de nuevo.');
    }
  }

  Future<void> _releaseRegistrationCodeReservation({
    required String emailNorm,
    required String codeNorm,
  }) async {
    final codeRef = _db.collection(_registrationCodesCollection).doc(codeNorm);
    final now = DateTime.now();

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(codeRef);
        if (!snap.exists) return;

        final data = snap.data()!;
        final reservedForEmail = (data['reservedForEmail'] as String?)?.toLowerCase();
        final reservedUntilTs = data['reservedUntil'] as Timestamp?;
        final reservedUntil = reservedUntilTs?.toDate();

        if (reservedForEmail == emailNorm && reservedUntil != null && reservedUntil.isAfter(now)) {
          tx.update(codeRef, {
            'reservedForEmail': null,
            'reservedUntil': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  void _applyFailedCodeAttempt({
    required Transaction tx,
    required DocumentReference<Map<String, dynamic>> lockRef,
    required String emailNorm,
    required DateTime now,
    required int currentAttempts,
  }) {
    final next = currentAttempts + 1;
    final lockedUntil = next >= _maxCodeAttempts ? Timestamp.fromDate(now.add(_lockDuration)) : null;

    tx.set(
      lockRef,
      {
        'email': emailNorm,
        'failedCodeAttempts': next,
        'lockedUntil': lockedUntil,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static String _lockedMessage(DateTime lockedUntil) {
    final diff = lockedUntil.difference(DateTime.now());
    final minutes = (diff.inSeconds / 60).ceil().clamp(1, 9999);
    if (minutes == 1) return 'Has agotado los intentos. Espera 1 minuto para volver a intentarlo.';
    return 'Has agotado los intentos. Espera $minutes minutos para volver a intentarlo.';
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}