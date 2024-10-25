import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventListPage extends StatefulWidget {
  final String? friendName;

  const EventListPage({super.key, this.friendName});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [
    {
      'name': 'Birthday Party',
      'category': 'Social',
      'status': 'Upcoming',
      'date': DateTime(2024, 1, 15),
    },
    {
      'name': 'Wedding',
      'category': 'Family',
      'status': 'Past',
      'date': DateTime(2023, 12, 22),
    },
    {
      'name': 'Office Meeting',
      'category': 'Work',
      'status': 'Current',
      'date': DateTime(2024, 2, 10),
    }
  ];

  String sortBy = 'name';

  void addEvent() {
    // Implementation to add a new event
  }

  void editEvent(int index) {
    // Implementation to edit the selected event
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    events.sort((a, b) => a[sortBy].compareTo(b[sortBy]));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.friendName}'s Event List",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                  context, '/profile'); // Navigate to profile page
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile_icon.png'),
                radius: 18.0,
              ),
            ),
          ),
        ],
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
        child: Column(
          children: [
            DropdownButton<String>(
              value: sortBy,
              dropdownColor: const Color.fromARGB(255, 58, 2, 80),
              onChanged: (value) {
                setState(() {
                  sortBy = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'name',
                  child: Text(
                    'Sort by Name',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: 'category',
                  child: Text(
                    'Sort by Category',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: 'status',
                  child: Text(
                    'Sort by Status',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  String formattedDate =
                      DateFormat('MMMM dd, yyyy').format(event['date']);
                  return Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(event['name']),
                      subtitle: Text(
                        '${event['category']} • ${event['status']} • $formattedDate',
                      ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add New Event'),
        onPressed: addEvent,
      ),
    );
  }
}
