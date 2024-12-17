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

    // If the gift is purchased, we hide the edit and delete buttons
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

    // If the gift is not purchased, show the buttons based on the pledge and purchase status
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!gift.isPledged && !gift.isPurchased && !isCreator)
          ElevatedButton(
            onPressed: () => _updatePledgeStatus(context, gift.id, true),
            child: const Text('Pledge'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        if (gift.isPledged && !gift.isPurchased && !isCreator)
          ElevatedButton(
            onPressed: () => _updatePurchaseStatus(context, gift.id, true),
            child: const Text('Purchase'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        if (isCreator)
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
        if (isCreator && !gift.isPledged)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            iconSize: 35,
            onPressed: () {
              FirestoreService().deleteGift(gift.id);
            },
          ),
      ],
    );
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