import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/title_widget.dart';
import 'package:hedieaty/views/event_list.dart'; // Import EventListPage
import 'package:hedieaty/views/create_event.dart'; // Import CreateEventPage
import 'package:hedieaty/models/user_model.dart'; // UserModel
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user; // Add a variable to store the logged-in user
  String _userName = ''; // Variable to hold the user's name

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser; // Fetch the logged-in user
    if (_user != null) {
      // Fetch the user's name from Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            _userName = doc['name']; // Assuming 'name' field exists in user document
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        title: const TitleWidget(),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profilePage');
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${_userName.isNotEmpty ? _userName : 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Friend"),
                    onPressed: () {
                      // Logic to add a new friend
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.event),
                    label: const Text(
                      'My Events',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      // Pass the userId to EventListPage to show the user's events
                      if (_user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventListPage(userId: _user!.uid),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a user...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Logic for search functionality
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  // Fetch users and build the list
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
                      return _buildUserCard(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: user.uid)
          .snapshots(), // Use snapshots to listen for real-time changes
      builder: (context, eventCountSnapshot) {
        if (eventCountSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventCountSnapshot.hasError) {
          return Center(child: Text('Error: ${eventCountSnapshot.error}'));
        }

        int eventCount = eventCountSnapshot.data?.docs.length ?? 0; // Get the count of events

        return Card(
          color: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/profile_icon.png'), // Default image
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                color: Color.fromARGB(255, 58, 2, 80),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(user.email),
            trailing: eventCount > 0
                ? CircleAvatar(
              radius: 12,
              backgroundColor: Colors.amber,
              child: Text(
                '$eventCount',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : null,
            onTap: () {
              // Pass the userId to the EventListPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventListPage(userId: user.uid),
                ),
              );
            },
          ),
        );
      },
    );
  }


  Future<int> _fetchEventCount(String userId) async {
    // Fetch the count of events for the user
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId) // Assuming events have a 'userId' field
        .get();

    return snapshot.size; // Return the count of events
  }
}
