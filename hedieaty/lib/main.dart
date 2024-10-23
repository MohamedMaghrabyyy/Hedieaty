import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 58, 2, 80),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hedieaty',
                  style: TextStyle(
                    fontSize: 36.0,
                    color: Color(0xFFF8F8FF),
                    fontWeight: FontWeight.bold,
                    fontFamily: "gvibes",
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.card_giftcard,
                  color: Color.fromARGB(255, 248, 220, 9),
                  size: 30.0,
                ),
              ],
            ),
            SizedBox(height: 50),
            SpinKitSpinningLines(
              color: Color(0xFFD3D3D3),
              size: 50.0,
            ),
            SizedBox(height: 20), 
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
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
