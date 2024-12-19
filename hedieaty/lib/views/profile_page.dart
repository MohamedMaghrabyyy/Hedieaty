import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/services/firebase_auth_service.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/views/event_list.dart';
import 'package:hedieaty/views/my_pledged_gifts.dart';
import 'package:hedieaty/views/event_list.dart';
import 'package:hedieaty/views/profile_details.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  void _logOut(BuildContext context) async {
    try {
      await FirebaseAuthService().signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Navigate to login page and remove all previous routes
    }
    catch (e)
    {
      print("Error logging out: $e");
    }
  }


  Future<String?> _getUserId() async {
    try {
      // Get the current user data using the FirestoreService method
      final userData = await FirestoreService().getCurrentUserData();
      return userData['uid']; // Assuming 'uid' is stored in the user document
    } catch (e) {
      print("Error fetching user ID: $e");
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
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
                // Navigate to the ProfileDetailsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileDetailsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.notifications),
              onTap: () {
                // Add navigation to notification settings
              },
            ),
            // "My Created Events" option
            ListTile(
              title: const Text('My Created Events'),
              trailing: const Icon(Icons.event),
              onTap: () async {
                final userId = await _getUserId();
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventListPage(userId: userId),
                    ),
                  );
                }
              },
            ),
            // "My Pledged Gifts" option
            ListTile(
              title: const Text('My Pledged Gifts'),
              trailing: const Icon(Icons.card_giftcard),
              onTap: () async {
                final userId = await _getUserId();
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPledgedGiftsPage(userId: userId),
                    ),
                  );
                }
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
