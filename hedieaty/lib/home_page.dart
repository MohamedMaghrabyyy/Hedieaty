import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'package:flutter/material.dart';
import 'title_widget.dart';
import 'package:hedieaty/event_list.dart';
import 'package:hedieaty/profile_page.dart';
import 'package:hedieaty/user_model.dart';  // Import UserModel

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            const Text(
              'Welcome, User!',
              style: TextStyle(
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
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Create Your Own Event/List',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/createEvent');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for friends’ gift lists...',
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

                  // Use ListView.builder to create list items
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var user = UserModel.fromMap(doc.data() as Map<String, dynamic>);

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
                          trailing: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.amber,
                            child: const Text(
                              '1',  // Default number of events
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventListPage(
                                  friendName: user.name,
                                ),
                              ),
                            );
                          },
                        ),
                      );
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
}
