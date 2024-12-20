import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  final String userId;

  const MyPledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserName();
  }

  Future<void> _fetchCurrentUserName() async {
    final fetchedUsername = await FirestoreService().getUsernameById(widget.userId);
    setState(() {
      username = fetchedUsername ?? 'Unknown User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username != null ? "$username's Pledged Gifts" : "My Pledged Gifts"),
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
          stream: FirestoreService().streamPledgedGiftsForUser(widget.userId), // Use the passed userId here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var gifts = snapshot.data ?? [];
            if (gifts.isEmpty) {
              return const Center(
                child: Text(
                  'No pledged gifts found.',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              );
            }

            return ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                return _buildGiftCard(context, gifts[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGiftCard(BuildContext context, GiftModel gift) {
    final bool isPurchased = gift.isPurchased;

    Color cardColor = Colors.grey[200]!;

    if (isPurchased) {
      cardColor = Colors.green[100]!; // Highlight purchased gifts in green
    }

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          gift.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,  // Reduced font size for better wrapping
            color: Color.fromARGB(255, 58, 2, 80),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // Allow wrapping, but show only 2 lines for the name
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Theme.of(context).primaryColor, size: 30),
                const SizedBox(width: 10),
                Expanded( // Ensures description wraps properly within available space
                  child: Text(
                    gift.description,
                    style: const TextStyle(color: Colors.black87, fontSize: 14), // Smaller font for better fit
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Limit to 2 lines to avoid overflow
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  '\$${gift.price}', // Display gift price
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  gift.isPurchased ? Icons.check_circle : Icons.cancel,
                  color: gift.isPurchased ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  gift.isPurchased ? 'Purchased' : 'Not Purchased',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildActionButtons(context, gift),
        isThreeLine: true,
        dense: false,
        onTap: () => _showGiftDetailsOverlay(context, gift),
      ),
    );
  }


  Widget _buildActionButtons(BuildContext context, GiftModel gift) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (gift.isPurchased)
          const Text(
            'Purchased',
            style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        if (!gift.isPurchased)
          ElevatedButton(
            onPressed: () {
              _updatePurchaseStatus(context, gift.id, true);
              setState(() {

              });
            },
            child: const Text('Mark as Purchased'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
      ],
    );
  }

  void _updatePurchaseStatus(BuildContext context, String giftId, bool status) async {
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

