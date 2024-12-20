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
    Future<int> _fetchEventCount(String userId) async {
      final eventDocs = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();
      return eventDocs.docs.length;
    }

    Future<int> _fetchGiftCount(String userId) async {
      final giftDocs = await FirebaseFirestore.instance
          .collection('gifts')
          .where('userId', isEqualTo: userId)
          .get();
      return giftDocs.docs.length;
    }

    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance
            .collection('friends')
            .where('userId1', isEqualTo: _user!.uid)
            .where('userId2', isEqualTo: user.uid)
            .get(),
        _fetchEventCount(user.uid),
        _fetchGiftCount(user.uid),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Data retrieval
        final isFriend =
            snapshot.data != null && (snapshot.data![0] as QuerySnapshot).docs.isNotEmpty;
        final eventCount = snapshot.data != null ? snapshot.data![1] as int : 0;
        final giftCount = snapshot.data != null ? snapshot.data![2] as int : 0;

        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            key: Key('userCard_${user.uid}'),
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(user.email, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Events Icon and Count with Badge Style
                _buildIconWithCount(
                  icon: Icons.event,
                  count: eventCount,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventListPage(userId: user.uid),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                // Gifts Icon and Count with Badge Style
                _buildIconWithCount(
                  icon: Icons.card_giftcard,
                  count: giftCount,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(userId: user.uid),
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
  }

  Widget _buildIconWithCount({required IconData icon, required int count, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF543CA6),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20), // Softer white color for the icon
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
              decoration: BoxDecoration(
                color: Colors.amber[100], // A lighter, more subdued amber for the badge
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.black87, // Darker text color for better readability
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Slightly smaller font size
                ),
              ),
            ),
          ],
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
