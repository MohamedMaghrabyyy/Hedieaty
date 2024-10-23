import 'package:flutter/material.dart';
import 'package:hedieaty/loading_screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/loading',
    routes: {
      '/loading': (context) => const LoadingScreen(),
      '/login': (context) => LoginPage(),
      '/home': (context) => HomeScreen(),
    },
  ));
}





class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Text('Welcome to the Home Screen'),
      ),
    );
  }
}
