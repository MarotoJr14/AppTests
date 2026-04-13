import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Login ────────────────────────────────────────────────────────────────
  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Password reset ───────────────────────────────────────────────────────
  /// Sends a password reset email.
  /// Throws [AuthException] with code 'user-not-found' if email not registered.
  Future<void> sendPasswordReset(String email) async {
    // Check if user exists by attempting sign-in with wrong password.
    // Firebase does NOT expose a direct "does this email exist?" API for security.
    // We rely on the auth error codes instead:
    //   - user-not-found → email not registered
    //   - wrong-password / invalid-credential → email exists
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('No existe ningún usuario con ese correo electrónico.');
      }
      rethrow;
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Create user profile in Firestore ────────────────────────────────────
  Future<void> createUserProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
