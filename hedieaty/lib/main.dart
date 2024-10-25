import 'package:flutter/material.dart';
import 'package:hedieaty/loading_screen.dart';
import 'package:hedieaty/sign_up.dart';
import 'package:hedieaty/login.dart';
import 'package:hedieaty/home_page.dart';
import 'package:hedieaty/event_list.dart';
import 'package:hedieaty/gift_list.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/giftListPage',
    routes: {
      '/loading': (context) => const LoadingScreen(),
      '/login': (context) => const LoginPage(),
      '/signup': (context) => const SignUpPage(),
      '/home': (context) => HomePage(),
      '/eventListPage': (context) => EventListPage(),
      '/giftListPage': (context) => GiftListPage(),
    },
  ));
}
