import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/views/edit_gift.dart';

class GiftListPage extends StatelessWidget {
  final List<GiftModel> gifts; // Assume this list is fetched from a database

  GiftListPage({required this.gifts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift List'),
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            title: Text(gift.name),
            subtitle: Text('Category: ${gift.category}\nStatus: ${gift.status}'),
            isThreeLine: true,
            onTap: () {
              // Navigate to the EditGiftPage with the selected gift
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditGiftPage(gift: gift),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
