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
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25), // Set text color to white
        title: FutureBuilder<String>(
          future: _fetchUserName(userId), // Fetch the user's name
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text("${snapshot.data}'s Events List"); // Display user's name
            } else {
              return const Text("Event List");
            }
          },
        ),
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
                    onTap: () {
                      _showEventDetailsOverlay(context, event);
                    },
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
                            if (event.userId == userId) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditEventPage(eventId: event.id),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You are not authorized to edit this event.')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (event.userId == userId) {
                              // Delete functionality...
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You are not authorized to delete this event.')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.card_giftcard, color: Colors.amber), // Replaced icon
                          onPressed: () {
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
                  )

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

  // Method to fetch the user's name from Firestore
  Future<String> _fetchUserName(String userId) async {
    try {
      final userDoc = await FirestoreService().getUserById(userId); // Get user by userId
      return userDoc?['name'] ?? 'User'; // Return the user's name or 'User' if not found
    } catch (e) {
      return 'Error fetching user';
    }
  }

  Stream<List<EventModel>> _fetchUserEvents(String userId) {
    return FirestoreService().streamEventsForUser(userId); // Fetch events for userId
  }
}
void _showEventDetailsOverlay(BuildContext context, EventModel event) async {
  // Fetch the name of the user who created the event
  String createdByName = await FirestoreService().getUserNameById(event.userId);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        title: Center(
          child: Text(
            event.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color.fromARGB(255, 58, 2, 80),
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(event.date),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.description, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.location ?? 'N/A',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Created By: $createdByName',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ),
        ],
      );
    },
  );
}


