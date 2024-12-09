import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
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
          ],
        ),
      ),
    );
  }
}
