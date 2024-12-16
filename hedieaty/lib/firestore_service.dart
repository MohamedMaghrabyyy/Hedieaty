import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:hedieaty/user_model.dart'; // Import the UserModel class

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to store user data in Firestore with auto-generated document ID
  Future<void> saveUserData(UserModel userModel) async {
    try {
      // Save the user data to Firestore under the 'users' collection with an auto-generated ID
      await _firestore.collection('users').add(userModel.toMap());
    } catch (e) {
      print("Error saving user data to Firestore: $e");
    }
  }

  // Method to get user data by userId (to be used when looking up users)
  Future<UserModel?> getUserData(String userId) async {
    try {
      // You would need some way to find the user document by userId if needed
      // This could be a custom field (e.g., email, or another unique identifier)
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userId) // or any other field you're using
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print("User not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}
