import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/views/gift_list.dart';
import 'package:hedieaty/widgets/title_widget.dart';
import 'package:hedieaty/views/event_list.dart'; // Import EventListPage
import 'package:hedieaty/models/user_model.dart'; // UserModel
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/services/firestore_service.dart'; // Import FirebaseAuth

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _userName = '';
  String _searchQuery = '';
  int _selectedIndex = 0;
  bool _isViewingFriendsOnly = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            _userName = doc['name'];
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

  Future<List<UserModel>> _fetchFriends() async {
    final friendDocs = await FirebaseFirestore.instance
        .collection('friends')
        .where('userId1', isEqualTo: _user!.uid)
        .get();

    final friendIds = friendDocs.docs.map((doc) => doc['userId2']).toList();

    if (friendIds.isEmpty) return []; // Handle no friends gracefully

    final userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .get();

    return userDocs.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> _fetchAllUsers() async {
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    return allUsers.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((user) => user.uid != _user!.uid)
        .toList();
  }

  Future<void> _addFriend(String userId1, String userId2) async {
    try {
      final friendData1 = {'userId1': userId1, 'userId2': userId2};
      final friendData2 = {'userId1': userId2, 'userId2': userId1};

      await FirebaseFirestore.instance.collection('friends').add(friendData1);
      await FirebaseFirestore.instance.collection('friends').add(friendData2);
    } catch (e) {
      print("Error adding friends: $e");
    }
  }

  Widget _buildToggleButton() {
    return ElevatedButton(
      key: Key('toggleViewButton'),
      onPressed: _toggleView,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 219, 144, 5), Colors.amber],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isViewingFriendsOnly ? Icons.people : Icons.group_add,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                _isViewingFriendsOnly
                    ? 'View All Users'
                    : 'View Friends Only',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  TextField _buildSearchField() {
    return TextField(
      key: Key('searchField'),
      decoration: InputDecoration(
        hintText: _isViewingFriendsOnly ? 'Search Friends...' : 'Search All Users...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
      onChanged: (query) {
        setState(() {
          _searchQuery = query.trim().toLowerCase();
        });
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return FutureBuilder<Map<String, int>>(
      future: _getUserEventAndGiftCounts(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final eventCount = snapshot.data?['eventCount'] ?? 0;
        final giftCount = snapshot.data?['giftCount'] ?? 0;

        // Check if user is a friend
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('friends')
              .where('userId1', isEqualTo: _user!.uid)
              .where('userId2', isEqualTo: user.uid)
              .get(),
          builder: (context, friendSnapshot) {
            if (friendSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final isFriend = friendSnapshot.hasData && friendSnapshot.data!.docs.isNotEmpty;

            return Card(
              elevation: 3.0, // Subtle shadow for depth
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Reduced margin
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // Slightly smaller border radius
              ),
              color: Colors.white, // White background for the card
              shadowColor: Colors.black.withOpacity(0.1), // Softer shadow
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Reduced padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                  color: Colors.white, // White background
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero, // No extra padding inside ListTile
                  key: Key('userCard_${user.uid}'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.black, // Black text for readability
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0, // Adjusted text size
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.black54, // Lighter black for the subtitle
                      fontSize: 14.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: _isViewingFriendsOnly // Show icons or add button based on the list
                      ? (isFriend
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('eventIcon_${user.uid}'),
                        onPressed: () {
                          // Navigate to the user's event list
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventListPage(userId: user.uid),
                            ),
                          );
                        },
                        icon: Icon(Icons.event, color: Colors.purple, size: 25), // Purple icons
                      ),
                      _buildCountBadge(eventCount), // Event count badge

                      IconButton(
                        key: Key('giftIcon_${user.uid}'),
                        onPressed: () {
                          // Navigate to the user's gift list
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftListPage(userId: user.uid),
                            ),
                          );
                        },
                        icon: Icon(Icons.card_giftcard, color: Colors.purple, size: 30), // Purple icons
                      ),
                      _buildCountBadge(giftCount), // Gift count badge
                    ],
                  )
                      : SizedBox()) // No action for non-friends in Friends Only list
                      : (isFriend
                      ? Icon(Icons.check, color: Colors.green) // Tick icon for friends
                      : IconButton(
                    key: Key('addFriendButton_${user.uid}'),
                    onPressed: () async {
                      if (_user != null) {
                        // Add friend to the user's friend list
                        _addFriend(_user!.uid, user.uid);

                        // Get current user's data from Firestore
                        final currentUserData = await FirestoreService().getCurrentUserData();
                        final String currentUserName = currentUserData['name'] ?? 'Someone';

                        // Create a notification for the user
                        await FirestoreService().createNotification(
                          user.uid,
                          '$currentUserName added you as a friend!',
                        );

                        setState(() {}); // Trigger UI update
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.purple),
                  )),
                ),
              ),
            );
          },
        );
      },
    );
  }

// Function to get counts of events and gifts for a specific user
  Future<Map<String, int>> _getUserEventAndGiftCounts(String userId) async {
    final eventCountQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();

    final giftCountQuery = await FirebaseFirestore.instance
        .collection('gifts')
        .where('userId', isEqualTo: userId)
        .get();

    return {
      'eventCount': eventCountQuery.size, // Number of events
      'giftCount': giftCountQuery.size,   // Number of gifts
    };
  }

// Widget for the small count badge
  Widget _buildCountBadge(int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
        decoration: BoxDecoration(
          color: Colors.amber[300], // Amber color for the badge circle
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          '$count', // Display the count
          style: const TextStyle(
            color: Colors.black87, // Dark text color for readability
            fontWeight: FontWeight.bold,
            fontSize: 13, // Smaller size for the badge
          ),
        ),
      ),
    );
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
              child: Icon(
                Icons.menu,
                key: Key('profilePageButton'),
                size: 30.0,  // Adjust the size as per your design
              ),
            ),
          )

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
            // Greeting Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Welcome, ${_userName.isNotEmpty ? _userName : 'User'}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildSearchField(),
            ),

            // Toggle Button for Switching Views
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildToggleButton(),
            ),

            // User List Label (Friends or All Users)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _isViewingFriendsOnly ? 'Friends:' : 'All users:',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // User List
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _isViewingFriendsOnly ? _fetchFriends() : _fetchAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  var users = snapshot.data ?? [];
                  if (_searchQuery.isNotEmpty) {
                    users = users
                        .where((user) => user.name.toLowerCase().contains(_searchQuery))
                        .toList();
                  }
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        _isViewingFriendsOnly ? 'No friends found.' : 'No users found.',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(users[index]);
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
            _selectedIndex = index;
          });

          if (_user != null) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventListPage(userId: _user!.uid),
                ),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftListPage(userId: _user!.uid),
                ),
              );
            }
          }
        },
        selectedItemColor: Colors.amber[300],
        unselectedItemColor: Colors.amber[300],
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        type: BottomNavigationBarType.fixed,
        iconSize: 30.0,
        selectedLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 18),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event, size: 40, key: Key('myEventsButton')),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard, size: 40, key: Key('myGiftsButton')),
            label: 'My Gifts',
          ),
        ],
      ),
    );
  }


}
