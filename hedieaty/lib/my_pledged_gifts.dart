import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [
    {
      'name': 'Smartphone',
      'friend': 'Alice',
      'dueDate': DateTime(2024, 1, 15),
      'status': 'Pending',
    },
    {
      'name': 'Book',
      'friend': 'Bob',
      'dueDate': DateTime(2023, 12, 30),
      'status': 'Completed',
    },
  ];

  void modifyGift(int index) {
    // Logic for modifying a pending gift
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 58, 2, 80),
              Color.fromARGB(255, 219, 144, 5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: pledgedGifts.length,
          itemBuilder: (context, index) {
            final gift = pledgedGifts[index];
            final formattedDate = "${gift['dueDate'].day}-${gift['dueDate'].month}-${gift['dueDate'].year}";
            final isPending = gift['status'] == 'Pending';

            return Card(
              color: isPending ? Colors.green[100] : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                title: Text(gift['name']),
                subtitle: Text(
                  'For: ${gift['friend']}\nDue: $formattedDate\nStatus: ${gift['status']}',
                ),
                trailing: isPending
                    ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () => modifyGift(index),
                )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
