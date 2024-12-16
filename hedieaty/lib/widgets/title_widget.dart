import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(Object context) {
    return const Row(
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
    );
  }
}
