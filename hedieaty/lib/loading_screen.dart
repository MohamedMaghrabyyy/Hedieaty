import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
                    fontSize: 45.0,
                    color: Color(0xFFF8F8FF),
                    fontWeight: FontWeight.bold,
                    fontFamily: "gvibes",
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.card_giftcard,
                  color: Color.fromARGB(255, 248, 220, 9),
                  size: 35.0,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Don't need gifts, I am the gift yeah.",
              style: TextStyle(
                fontFamily: 'arima',
                fontSize: 18.0,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
