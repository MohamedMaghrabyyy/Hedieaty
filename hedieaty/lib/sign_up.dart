import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import the FirebaseAuth User class
import 'package:hedieaty/firebase_auth_service.dart';
import 'package:hedieaty/firestore_service.dart';
import 'package:hedieaty/user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> signupKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // Phone number controller

  final FirebaseAuthService _authService = FirebaseAuthService(); // Instance of FirebaseAuthService
  final FirestoreService _firestoreService = FirestoreService(); // Instance of FirestoreService

  // Sign up method
  void _signUp() async {
    if (signupKey.currentState?.validate() ?? false) {
      try {
        // Sign up the user with FirebaseAuth
        User? user = await _authService.signUp(
          emailController.text,
          passwordController.text,
        );

        if (user != null) {
          // Create a UserModel object to store user details (email, name, and phone number)
          UserModel userModel = UserModel(
            email: emailController.text,
            name: nameController.text,
            phoneNumber: phoneController.text,
          );

          // After the user is created, save user data to Firestore
          await _firestoreService.saveUserData(
            user.uid, // Firebase user UID
            userModel, // UserModel to store in Firestore
          );

          // Navigate to home page after successful sign-up and data saving
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Handle sign-up error (show an alert or error message)
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 2, 80),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 280,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 58, 2, 80),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Form(
                key: signupKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your Name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your Email...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your password...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 200, 200, 200)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your Phone Number...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _signUp, // Call the sign-up method
                      child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Already have an account? Login!",
                        style: TextStyle(
                          color: Colors.amber,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
