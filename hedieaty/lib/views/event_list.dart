import 'package:flutter/material.dart';
import 'package:hedieaty/views/create_event.dart'; // Import CreateEventPage
import 'package:hedieaty/views/gift_list.dart'; // Import GiftListPage
import 'package:hedieaty/views/edit_event.dart'; // Import EditEventPage
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/firestore_service.dart';

class EventListPage extends StatefulWidget {
  final String? friendName;

  const EventListPage({super.key, this.friendName});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void addEvent() async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventPage(), // Navigate to CreateEventPage
      ),
    );

    if (newEvent != null) {
      setState(() {
        // If new event is created, you may want to add it to Firestore.
        // You can use _firestoreService.addEvent(newEvent) here if needed.
      });
    }
  }

  void editEvent(EventModel event) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(existingEvent: event), // Pass EventModel
      ),
    );

    if (updatedEvent != null) {
      setState(() {
        // Update event in list after editing, may need to push the update to Firestore as well.
      });
    }
  }

  void deleteEvent(EventModel event) async {
    await _firestoreService.deleteEvent(event.id); // Delete event from Firestore
    setState(() {
      // Update UI after deletion.
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
        child: StreamBuilder<List<EventModel>>(
          stream: _firestoreService.getAllEvents(), // Use Firestore stream
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No events available.'));
            }

            final events = snapshot.data!;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Text(event.name),
                    subtitle: Text(event.date.toLocal().toString().split(' ')[0]),
                    onTap: () => navigateToGiftList(event.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => editEvent(event),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteEvent(event),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
