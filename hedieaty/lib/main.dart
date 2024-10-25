import 'package:flutter/material.dart';
import 'package:hedieaty/loading_screen.dart';
import 'package:hedieaty/sign_up.dart';
import 'package:hedieaty/login.dart';
import 'package:hedieaty/home_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/loading',
    routes: {
      '/loading': (context) => const LoadingScreen(),
      '/login': (context) => const LoginPage(),
      '/signup': (context) => const SignUpPage(),
      '/home': (context) => HomePage(),
    },
  ));
}

