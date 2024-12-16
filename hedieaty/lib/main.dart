import 'package:flutter/material.dart';
import 'package:hedieaty/views/loading_screen.dart';
import 'package:hedieaty/views/sign_up.dart';
import 'package:hedieaty/views/login.dart';
import 'package:hedieaty/views/home_page.dart';
import 'package:hedieaty/views/event_list.dart';
import 'package:hedieaty/views/gift_list.dart';
import 'package:hedieaty/views/my_pledged_gifts.dart';
import 'package:hedieaty/views/profile_page.dart';
import 'package:hedieaty/views/create_event.dart';
import 'package:hedieaty/views/edit_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hedieaty/services/firebase_options.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/models/gift_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const HomePage(),
        '/eventListPage': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as String;
          return EventListPage(userId: userId); // Pass the userId to EventListPage
        },
        '/giftListPage': (context) {
          final eventId = ModalRoute.of(context)?.settings.arguments as String;
          return GiftListPage(eventId: eventId); // Pass eventId instead
        },
        '/myPledgedGifts': (context) => const MyPledgedGiftsPage(),
        '/profilePage': (context) => const ProfilePage(),
        '/createEvent': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as String;
          return CreateEventPage(userId: userId); // Pass the userId to CreateEventPage
        },
        '/editEvent': (context) {
          final eventId = ModalRoute.of(context)?.settings.arguments as String;
          return EditEventPage(eventId: eventId); // Pass only the eventId
        },
      },
    );
  }
}
