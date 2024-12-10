import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:hedieaty/user_model.dart'; // Import the UserModel class

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to store user data in Firestore after authentication
  Future<void> saveUserData(String userId, UserModel userModel) async {
    try {
      // Save the user data to Firestore under the 'users' collection
      await _firestore.collection('users').doc(userId).set(userModel.toMap());
    } catch (e) {
      print("Error saving user data to Firestore: $e");
    }
  }
}
