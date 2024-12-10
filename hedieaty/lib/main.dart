import 'package:flutter/material.dart';
import 'package:hedieaty/loading_screen.dart';
import 'package:hedieaty/sign_up.dart';
import 'package:hedieaty/login.dart';
import 'package:hedieaty/home_page.dart';
import 'package:hedieaty/event_list.dart';
import 'package:hedieaty/gift_list.dart';
import 'package:hedieaty/my_pledged_gifts.dart';
import 'package:hedieaty/profile_page.dart';
import 'package:hedieaty/create_event.dart';
import 'package:hedieaty/edit_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hedieaty/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
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
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/eventListPage': (context) => const EventListPage(),
        '/giftListPage': (context) => const GiftListPage(),
        '/myPledgedGifts': (context) => const MyPledgedGiftsPage(),
        '/profilePage': (context) => const ProfilePage(),
        '/createEvent': (context) => const CreateEventPage(),
        '/editEvent': (context) => (ModalRoute.of(context)?.settings.arguments != null)
            ? EditEventPage(
          existingEvent: ModalRoute.of(context)!.settings.arguments as Map<String, String>,
        )
            : const EditEventPage(),
      },
    );
  }
}
