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
        '/eventListPage': (context) => const EventListPage(),
        '/giftListPage': (context) => const GiftListPage(),
        '/myPledgedGifts': (context) => const MyPledgedGiftsPage(),
        '/profilePage': (context) => const ProfilePage(),
        '/createEvent': (context) => const CreateEventPage(),
        '/editEvent': (context) => (ModalRoute.of(context)?.settings.arguments != null)
            ? EditEventPage(
          existingEvent: ModalRoute.of(context)!.settings.arguments as EventModel,
        )
            : const EditEventPage(),
      },
    );
  }
}
