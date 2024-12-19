import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/views/edit_gift.dart';
import 'package:hedieaty/views/create_gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftListPage extends StatefulWidget {
  final String? eventId;
  final String? userId;

  const GiftListPage({Key? key, this.eventId, this.userId}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late Stream<List<GiftModel>> _giftsStream;
  String? eventOwnerId;
  String? username; // To store the fetched username
  String? eventName; // To store the fetched event name

  @override
  void initState() {
    super.initState();
    _initializeGiftStream();
    if (widget.eventId != null) {
      _fetchEventOwner(widget.eventId);
      _fetchEventName(widget.eventId); // Fetch event name
    }
    if (widget.userId != null) {
      _fetchUsername(widget.userId); // Fetch username for userId
    }
  }

  void _initializeGiftStream() {
    if (widget.userId != null) {
      _giftsStream = FirestoreService().streamGiftsForUser(widget.userId!);
    } else if (widget.eventId != null) {
      _giftsStream = FirestoreService().streamGiftsForEvent(widget.eventId!);
    } else {
      _giftsStream = Stream.value([]); // Empty stream if no filters provided
    }
  }

  Future<void> _fetchEventOwner(String? eventId) async {
    if (eventId == null) return;

    final event = await FirestoreService().getEventById(eventId);
    setState(() {
      eventOwnerId = event?.userId;
    });
  }

  Future<void> _fetchUsername(String? userId) async {
    if (userId == null) return;

    // Fetch username using the Firestore service
    final fetchedUsername = await FirestoreService().getUsernameById(userId);

    // Update the state with the fetched username
    setState(() {
      username = fetchedUsername ?? 'Unknown User'; // Fallback if no username is found
    });

  }


  Future<void> _fetchEventName(String? eventId) async {
    if (eventId == null) return;

    final event = await FirestoreService().getEventById(eventId);
    setState(() {
      eventName = event?.name; // Assuming 'name' is in EventModel
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
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
          stream: _giftsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final gifts = snapshot.data ?? [];

            if (gifts.isEmpty) {
              return const Center(
                child: Text(
                  'No gifts found.',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              );
            }

            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return _buildGiftCard(context, gift);
              },
            );
          },
        ),
      ),
      floatingActionButton: _showAddGiftButton()
          ? FloatingActionButton.extended(
        key: const Key('addGiftButton'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateGiftPage(eventId: widget.eventId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Gift'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      )
          : null,
    );
  }

  bool _showAddGiftButton() {
    return widget.eventId != null &&
        eventOwnerId == FirebaseAuth.instance.currentUser?.uid;
  }

  String _getAppBarTitle() {
    if (widget.eventId != null && eventName != null) {
      return "$eventName's Gifts";
    } else if (widget.userId != null && username != null) {
      return "$username's Gifts";
    } else {
      return "Gifts";
    }
  }

  Widget _buildGiftCard(BuildContext context, GiftModel gift) {
    final bool isPledged = gift.isPledged;
    final bool isPurchased = gift.isPurchased;

    Color cardColor = Colors.grey[200]!;

    if (isPurchased) {
      cardColor = Colors.green[100]!; // Highlight purchased gifts in green
    } else if (isPledged) {
      cardColor = Colors.red[100]!; // Highlight pledged gifts in red
    }

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _showGiftDetailsOverlay(context, gift),
        title: Text(
          gift.name,
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
                Icon(Icons.description, color: Theme.of(context).primaryColor, size: 30),
                const SizedBox(width: 10),
                Text(
                  gift.description,
                  style: const TextStyle(color: Colors.black87, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${gift.price}',
                  style: const TextStyle(color: Colors.black87, fontSize: 20),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildActionButtons(context, gift),
        isThreeLine: true,
        dense: false,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GiftModel gift) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final bool isCreator = gift.userId == currentUserId;

    // Get the current user's name from Firestore
    Future<String> getCurrentUserName(String currentUserId) async {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        final data = userDoc.data(); // Safe access to data
        return data != null ? data['name'] ?? 'Someone' : 'Someone';
      } else {
        return 'Someone';
      }
    }

    // Get the gift owner's name from Firestore
    Future<String> getGiftOwnerName(String userId) async {
      final giftOwnerSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (giftOwnerSnapshot.exists) {
        final data = giftOwnerSnapshot.data();
        return data != null ? data['name'] ?? 'User' : 'User';
      } else {
        return 'User';
      }
    }

    if (gift.isPurchased) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Purchased',
            style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return FutureBuilder<bool>(
      future: _canPurchaseGift(currentUserId, gift),
      builder: (context, snapshot) {
        final canPurchase = snapshot.data ?? false;
        final bool isPledger = gift.isPledged && canPurchase;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!gift.isPurchased && !isCreator)
              if (isPledger)
                ...[
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Update purchase status to true
                        await FirestoreService().updateGiftPurchaseStatus(gift.id, true);

                        // Get current user's name for notification
                        final currentUserName = await getCurrentUserName(currentUserId);
                        final giftOwnerName = await getGiftOwnerName(gift.userId);

                        // Notify the gift creator that the gift was purchased
                        await FirestoreService().createNotification(
                          gift.userId,
                          'Your gift "${gift.name}" has been purchased by $currentUserName!',
                        );

                        // Notify the current user about the successful purchase
                        await FirestoreService().createNotification(
                          currentUserId,
                          'You have purchased "${gift.name}" for $giftOwnerName.',
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gift purchased successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
                    child: const Text('Purchase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),

                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Remove the pledge from the pledges table
                        await FirestoreService().deletePledge(currentUserId, gift.id);
                        // Update the gift's pledge status
                        await FirestoreService().updateGiftPledgeStatus(gift.id, false);

                        final giftOwnerName = await getGiftOwnerName(gift.userId);

                        // Create a notification for the gift creator
                        await FirestoreService().createNotification(
                          gift.userId,
                          'The pledge for your gift "${gift.name}" has been removed.',
                        );

                        // Notify the current user about the pledge removal
                        await FirestoreService().createNotification(
                          currentUserId,
                          'You have removed your pledge for "${gift.name}".',
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pledge removed!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
                    child: const Text('Unpledge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ]
              else if (gift.isPledged)
                const Text(
                  'Pledged',
                  style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Add a pledge entry in the pledges table
                      await FirestoreService().createPledge(currentUserId, gift.id);
                      // Update the gift's pledge status
                      await FirestoreService().updateGiftPledgeStatus(gift.id, true);

                      // Get current user's name for notification
                      final currentUserName = await getCurrentUserName(currentUserId);
                      final giftOwnerName = await getGiftOwnerName(gift.userId);

                      // Notify the gift creator that the gift has been pledged
                      await FirestoreService().createNotification(
                        gift.userId,
                        '$currentUserName has pledged "${gift.name}" for you!',
                      );

                      // Notify the current user about the successful pledge
                      await FirestoreService().createNotification(
                        currentUserId,
                        'You have pledged "${gift.name}" for $giftOwnerName.',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pledged successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Pledge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
            if (isCreator && !gift.isPledged && !gift.isPurchased)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.amber),
                iconSize: 35,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGiftPage(gift: gift, giftId: gift.id),
                    ),
                  );
                },
              ),
            if (isCreator && !gift.isPledged && !gift.isPurchased)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                iconSize: 35,
                onPressed: () {
                  FirestoreService().deleteGift(gift.id);
                },
              ),
          ],
        );
      },
    );
  }



  Future<bool> _canPurchaseGift(String currentUserId, GiftModel gift) async {
    if (gift.userId == currentUserId) return true;

    // Check if the current user has pledged this gift
    return await FirestoreService().isGiftPledgedByUser(currentUserId, gift.id);
  }





  void _updatePledgeStatus(BuildContext context, String giftId, bool status) async {
    await FirestoreService().updateGiftPledgeStatus(giftId, status);
    setState(() {}); // Refresh the UI after the change
  }


  Future<void> _updatePurchaseStatus(BuildContext context, String giftId, bool status) async {
    await FirestoreService().updateGiftPurchaseStatus(giftId, status);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift purchase status updated')),
    );
  }

  void _showGiftDetailsOverlay(BuildContext context, GiftModel gift) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              gift.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.category, color: Colors.amber),
                title: Text(gift.category),
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.amber),
                title: Text(gift.description),
              ),
              ListTile(
                leading: Icon(Icons.attach_money, color: Colors.amber),
                title: Text('\$${gift.price}'),
              ),
              ListTile(
                leading: Icon(
                  gift.isPledged ? Icons.check_circle : Icons.cancel,
                  color: gift.isPledged ? Colors.green : Colors.red,
                ),
                title: Text('Pledged: ${gift.isPledged ? 'Yes' : 'No'}'),
              ),
              ListTile(
                leading: Icon(
                  gift.isPurchased ? Icons.check_circle : Icons.cancel,
                  color: gift.isPurchased ? Colors.green : Colors.red,
                ),
                title: Text('Purchased: ${gift.isPurchased ? 'Yes' : 'No'}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}