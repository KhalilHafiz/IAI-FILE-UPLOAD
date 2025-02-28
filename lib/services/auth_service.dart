import 'package:easy_upload/models/candidate.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Sign in with email and password
  Future<User?> signIn(Candidate candidate) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: candidate.email,
        password: candidate.password!,
      );

      return result.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signUp(Candidate candidate) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: candidate.email,
        password: candidate.password!,
      );
      return result.user;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}