import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/views/edit_event.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:hedieaty/views/create_event.dart'; // Import CreateEventPage

class EventListPage extends StatelessWidget {
  final String userId;

  EventListPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80), // Match color scheme
        iconTheme: const IconThemeData(color: Colors.white), // Ensure icons match app bar style
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
          stream: _fetchUserEvents(userId), // Stream of events for userId
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No events found.', style: TextStyle(color: Colors.white, fontSize: 25)));
            }

            final events = snapshot.data!;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                // Format the event date
                String formattedDate = DateFormat('MMM dd, yyyy').format(event.date);

                return Card(
                  color: Colors.grey[200],
                  elevation: 4, // Add elevation for shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 58, 2, 80),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.description),
                        const SizedBox(height: 4),
                        Text(
                          'Date: $formattedDate',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            // Navigate to the Edit Event Page with eventId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditEventPage(eventId: event.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Delete the event from Firestore
                            _deleteEvent(context, event.id);
                          },
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(userId: userId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        tooltip: 'Create Event',
      ),
    );
  }

  Stream<List<EventModel>> _fetchUserEvents(String userId) {
    return FirestoreService().streamEventsForUser(userId); // Fetch events for userId
  }

  void _deleteEvent(BuildContext context, String? eventId) {
    FirestoreService().deleteEvent(eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted')),
    );
  }
}
