import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/views/gift_list.dart';
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
  String _searchQuery = ''; // Search query for filtering users
  int _selectedIndex = 0; // Index for the BottomNavigationBar
  bool _isViewingFriendsOnly = false; // State to toggle between all users and friends

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

  void _toggleView() {
    setState(() {
      _isViewingFriendsOnly = !_isViewingFriendsOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          iconTheme: const IconThemeData(color: Colors.white),
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
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Toggle button to switch between friends and all users
              ElevatedButton(
                onPressed: _toggleView,
                child: Text(_isViewingFriendsOnly ? 'View All Users' : 'View Friends Only'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
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
                  setState(() {
                    _searchQuery = value.toLowerCase(); // Filter users as you type
                  });
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

                    // Filter users based on the search query and viewing option
                    var users = snapshot.data!.docs
                        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
                        .where((user) =>
                    user.name.toLowerCase().contains(_searchQuery) &&
                        (user.uid != _user!.uid)) // Exclude current user
                        .toList();

                    // Build user list
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index];
                        return _buildUserCard(user);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Update selected index for visual feedback
            });

            if (_user != null) {
              if (index == 0) {
                // My Events Page Navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventListPage(userId: _user!.uid),
                  ),
                );
              } else if (index == 1) {
                // My Gifts Page Navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(userId: _user!.uid),
                  ),
                );
              }
            }
          },
          selectedItemColor: Colors.amber[300],  // Active icon and text color
          unselectedItemColor: Colors.amber[300], // Inactive icon and text color
          backgroundColor: const Color.fromARGB(255, 58, 2, 80), // Background color
          type: BottomNavigationBarType.fixed,
          iconSize: 30.0, // Increased size of icons
          selectedLabelStyle: const TextStyle(
            fontSize: 18, // Make label text bigger
            fontWeight: FontWeight.bold, // Optional: make label bold
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 18, // Smaller text for unselected items
            fontWeight: FontWeight.normal, // Optional: make label normal weight
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.event, size: 40), // Increased icon size
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard, size: 40), // Increased icon size
              label: 'My Gifts',
            ),
          ],
        )

    );
  }
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

      return GestureDetector(
        onTap: () {
          // Navigate to the EventListPage for the selected user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventListPage(userId: user.uid), // Pass the selected user's UID
            ),
          );
        },
        child: Card(
          color: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User info section
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/profile_icon.png'), // Default image
                      radius: 30.0, // Increase the size of the avatar
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 58, 2, 80),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0, // Increased font size for name
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0, // Increased font size for email
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Event count section
                if (eventCount > 0)
                  CircleAvatar(
                    radius: 20, // Increased size of the circle on the right
                    backgroundColor: Colors.amber,
                    child: Text(
                      '$eventCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
