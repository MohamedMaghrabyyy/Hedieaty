import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart';  // FirestoreService
import 'package:hedieaty/models/user_model.dart';        // UserModel

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // Method to handle sign-up process
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get user input from the form fields
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        String name = _nameController.text.trim();

        // Create a new user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Create a UserModel instance
        UserModel newUser = UserModel(
          name: name,
          email: email,
          // Add any additional user fields here
        );

        // Save the user data in Firestore (Firestore will generate the document ID)
        await FirestoreService().saveUserData(newUser);

        // After sign-up, navigate to the home screen or wherever needed
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // Handle sign-up errors and display appropriate error messages
        String errorMessage = 'Sign-up failed. Please try again.';

        if (e is FirebaseAuthException) {
          if (e.code == 'weak-password') {
            errorMessage = 'Password is too weak. Please choose a stronger password.';
          } else if (e.code == 'email-already-in-use') {
            errorMessage = 'An account already exists for this email.';
          } else if (e.code == 'invalid-email') {
            errorMessage = 'The email address is badly formatted.';
          } else if (e.code == 'operation-not-allowed') {
            errorMessage = 'Email/password accounts are not enabled.';
          }
        }

        // Show the error in a snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              // Email input
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              // Password input
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password should be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Sign up button
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
