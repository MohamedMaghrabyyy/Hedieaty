import 'package:flutter/material.dart';
import 'package:hedieaty/loading_screen.dart';
import 'package:hedieaty/sign_up.dart';
import 'package:hedieaty/login.dart';
import 'package:hedieaty/home_page.dart';
import 'package:hedieaty/event_list.dart'; // Import the EventListPage
import 'package:hedieaty/gift_list.dart'; // Import the GiftListPage

void main() {
  runApp(MaterialApp(
    initialRoute: '/giftListPage',
    routes: {
      '/loading': (context) => const LoadingScreen(),
      '/login': (context) => const LoginPage(),
      '/signup': (context) => const SignUpPage(),
      '/home': (context) => HomePage(),
      '/eventListPage': (context) => EventListPage(), // Route for EventListPage
      '/giftListPage': (context) => GiftListPage(), // New route for GiftListPage
    },
  ));
}
