import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/views/create_event.dart';
import 'package:hedieaty/views/gift_list.dart'; // Import GiftListPage
import 'package:intl/intl.dart';
import 'package:hedieaty/views/edit_event.dart';

class EventListPage extends StatelessWidget {
  final String userId;

  EventListPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25), // Set text color to white
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
          stream: _fetchUserEvents(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No events found.',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              );
            }

            final events = snapshot.data!;

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                String formattedDate = DateFormat('MMM dd, yyyy').format(event.date);

                return Card(
                  color: Colors.grey[200],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
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
                    subtitle: Text(
                      'Date: $formattedDate\n${event.description}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            // Navigate to Edit Event Page with the event ID
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
                          onPressed: () async {
                            // Implement the event delete functionality
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Event'),
                                  content: const Text('Are you sure you want to delete this event?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete == true) {
                              try {
                                // Call FirestoreService to delete the event
                                await FirestoreService().deleteEvent(event.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Event deleted successfully.')),
                                );
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete event: $error')),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.amber),
                          onPressed: () {
                            // Navigate to Gift List Page with event ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftListPage(eventId: event.id),
                              ),
                            );
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
      ),
    );
  }

  Stream<List<EventModel>> _fetchUserEvents(String userId) {
    return FirestoreService().streamEventsForUser(userId); // Fetch events for userId
  }
}
