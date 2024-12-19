import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/views/create_event.dart';
import 'package:hedieaty/views/gift_list.dart'; // Import GiftListPage
import 'package:intl/intl.dart';
import 'package:hedieaty/views/edit_event.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class EventListPage extends StatelessWidget {
  final String userId;

  EventListPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get the current authenticated user

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
        title: FutureBuilder<String>(
          future: _fetchUserName(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text("${snapshot.data}'s Events List");
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
                        fontSize: 30,
                        color: Color.fromARGB(255, 58, 2, 80),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.black87, fontSize: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 30),
                            const SizedBox(width: 10),
                            // Adjust location text to wrap and avoid overflow
                            Expanded(
                              child: Text(
                                event.location, // Replace description with location
                                style: const TextStyle(color: Colors.black87, fontSize: 20),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis, // Optionally handle text overflow
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (event.userId == currentUserId) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            iconSize: 35,
                            onPressed: () {
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
                            iconSize: 35,
                            onPressed: () async {
                              await FirestoreService().deleteEventAndGifts(event.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Event deleted successfully')),
                              );
                            },
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.card_giftcard, color: Colors.amber),
                          iconSize: 35,
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
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: currentUserId == userId
          ? FloatingActionButton.extended(
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
      )
          : null,
    );
  }



  Future<String> _fetchUserName(String userId) async {
    try {
      final userDoc = await FirestoreService().getUserById(userId);
      return userDoc?['name'] ?? 'User';
    } catch (e) {
      return 'Error fetching user';
    }
  }

  Stream<List<EventModel>> _fetchUserEvents(String userId) {
    return FirestoreService().streamEventsForUser(userId);
  }

  void _showEventDetailsOverlay(BuildContext context, EventModel event) async {
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
}
