import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(messageFor(e.code));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(messageFor(e.code));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  static String messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return 'Wrong email or password.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }
}