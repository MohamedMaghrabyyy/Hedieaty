import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/views/edit_gift.dart';
import 'package:hedieaty/views/create_gift.dart';

class GiftListPage extends StatelessWidget {
  final String? eventId; // Event ID to filter gifts

  GiftListPage({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _fetchEventName(eventId), // Fetch event name based on eventId
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...'); // Show loading text until event name is fetched
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData) {
              return Text('${snapshot.data}\'s Gifts'); // Display event name
            }
            return const Text('Event Not Found');
          },
        ),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: StreamBuilder<List<GiftModel>>(
          stream: _fetchGiftsForEvent(eventId), // Stream gifts for the given event ID
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
                  'No gifts found for this event.',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              );
            }

            final gifts = snapshot.data!;

            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];

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
                      gift.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 58, 2, 80),
                      ),
                    ),
                    subtitle: Text(
                      'Category: ${gift.category}\nStatus: ${gift.status}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditGiftPage(
                                  giftId: gift.id, // Pass giftId
                                  gift: gift,      // Pass the GiftModel object
                                ),
                              ),
                            );
                          },
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Gift'),
                                  content: const Text('Are you sure you want to delete this gift?'),
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
                                // Call FirestoreService to delete the gift
                                await FirestoreService().deleteGift(gift.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gift deleted successfully.')),
                                );
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete gift: $error')),
                                );
                              }
                            }
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
              builder: (context) => CreateGiftPage(eventId: eventId), // Pass the eventId to CreateGiftPage
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Gift'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
    );
  }

  Stream<List<GiftModel>> _fetchGiftsForEvent(String? eventId) {
    return FirestoreService().streamGiftsForEvent(eventId); // Fetch gifts for a specific event
  }

  // Fetch event name by eventId
  Future<String> _fetchEventName(String? eventId) async {
    final event = await FirestoreService().getEventById(eventId); // FirestoreService to fetch event by id
    return event?.name ?? 'Event'; // Return event name or 'Event' if not found
  }
}
