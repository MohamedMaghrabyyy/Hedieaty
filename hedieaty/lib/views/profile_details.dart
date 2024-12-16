import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart'; // Firestore service to update user data

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({Key? key}) : super(key: key);

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Password controller

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Method to fetch current user data
  Future<void> _fetchUserData() async {
    try {
      final userData = await FirestoreService().getCurrentUserData(); // Fetch user data
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        // Do not pre-fill password for security reasons, leave it blank
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Method to save updated user data (name, email, password)
  Future<void> _saveProfile() async {
    try {
      // If password is provided, change the password
      if (_passwordController.text.isNotEmpty) {
        await FirestoreService().changePassword(_passwordController.text);
      }

      // Update name and email
      await FirestoreService().updateUserProfile(
        _nameController.text,
        _emailController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated successfully!'),
      ));
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Personal Information'),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300], // Placeholder background color
              child: const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.white, // Icon color
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true, // Ensure password is hidden
              decoration: const InputDecoration(labelText: 'New Password (Leave empty to keep current)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
