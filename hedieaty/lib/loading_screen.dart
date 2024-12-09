import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hedieaty/title_widget.dart';
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
      Navigator.pushReplacementNamed(context, '/login');
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
            TitleWidget(),
            SizedBox(height: 20),
            Text(
              "Gifting made easy!",
              style: TextStyle(
                fontFamily: 'arima',
                fontSize: 18.0,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 50),
            SpinKitSpinningLines(
              color: Colors.amber,
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
