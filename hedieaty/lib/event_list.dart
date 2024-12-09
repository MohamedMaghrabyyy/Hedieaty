import 'package:flutter/material.dart';
import 'package:hedieaty/create_event.dart'; // Import the CreateEventPage
import 'package:hedieaty/gift_list.dart'; // Import the GiftListPage
import 'package:hedieaty/edit_event.dart'; // Import the EditEventPage

class EventListPage extends StatefulWidget {
  final String? friendName;

  const EventListPage({super.key, this.friendName});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, String>> events = [
    {'name': 'Birthday Party', 'date': '2024-12-15'},
    {'name': 'Wedding', 'date': '2024-12-20'},
  ];

  void addEvent() async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventPage(), // Navigate to CreateEventPage
      ),
    );

    if (newEvent != null) {
      setState(() {
        events.add(newEvent);
      });
    }
  }

  void editEvent(int index) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          existingEvent: events[index], // Pass the existing event to be edited
        ),
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        events[index] = updatedEvent;
      });
    }
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  void navigateToGiftList(String eventName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftListPage(eventName: eventName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.friendName}'s Events",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
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
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                title: Text(event['name']!),
                subtitle: Text(event['date']!),
                onTap: () => navigateToGiftList(event['name']!), // Navigate to GiftListPage
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () => editEvent(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteEvent(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        onPressed: addEvent,
      ),
    );
  }
}
