import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up method with email and password only
  Future<User?> signUp(String email, String password) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Return the user object
      return userCredential.user;
    } catch (e) {
      print("Sign up error: $e");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Login error: $e");

      // Rethrow the error so it can be handled in the calling function
      throw e;
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }


  // Log out method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
