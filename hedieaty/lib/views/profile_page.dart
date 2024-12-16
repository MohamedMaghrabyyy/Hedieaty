import 'package:flutter/material.dart';
import 'package:hedieaty/services/firebase_auth_service.dart'; // Import the FirebaseAuthService

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Method to log out the user
  void _logOut(BuildContext context) async {
    try {
      await FirebaseAuthService().signOut(); // Sign out using FirebaseAuthService
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login page
    } catch (e) {
      // Handle any errors that might occur during logout
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Update Personal Information'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Add navigation to edit profile info
              },
            ),
            ListTile(
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.notifications),
              onTap: () {
                // Add navigation to notification settings
              },
            ),
            ListTile(
              title: const Text('My Created Events'),
              trailing: const Icon(Icons.event),
              onTap: () {
                // Add navigation to created events
              },
            ),
            ListTile(
              title: const Text('My Pledged Gifts'),
              trailing: const Icon(Icons.card_giftcard),
              onTap: () {
                Navigator.pushNamed(context, '/myPledgedGifts');
              },
            ),
            const Divider(), // Divider to separate logout option
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.exit_to_app),
              onTap: () => _logOut(context), // Call logout function
            ),
          ],
        ),
      ),
    );
  }
}
