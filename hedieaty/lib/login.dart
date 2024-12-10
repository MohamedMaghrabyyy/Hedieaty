import 'package:flutter/material.dart';
import 'package:hedieaty/title_widget.dart';
import 'package:hedieaty/firebase_auth_service.dart'; // Import the FirebaseAuthService
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> loginKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService(); // Instance of FirebaseAuthService
  String _errorMessage = ''; // To hold any error message

  // Login method
  void _login() async {
    if (loginKey.currentState?.validate() ?? false) {
      try {
        User? user = await _authService.signIn(
          emailController.text,
          passwordController.text,
        );
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // If login fails, update the error message
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });
        // Optionally, display a Snackbar for instant feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
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
            const TitleWidget(),
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
                key: loginKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                    // Display the error message if there's one
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _login, // Call the login method
                      child: const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        "Don't have an account? Sign up!",
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
