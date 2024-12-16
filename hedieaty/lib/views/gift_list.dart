import 'package:flutter/material.dart';
import 'package:hedieaty/views/gift_details.dart';

class GiftListPage extends StatefulWidget {
  final String? eventName;

  const GiftListPage({super.key, this.eventName});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Map<String, dynamic>> gifts = [
    {
      'name': 'Smartphone',
      'category': 'Electronics',
      'status': 'Available',
      'price': 999.99,
      'pledged': false,
    },
    {
      'name': 'Book',
      'category': 'Books',
      'status': 'Pledged',
      'price': 19.99,
      'pledged': true,
    },
    {
      'name': 'Watch',
      'category': 'Accessories',
      'status': 'Available',
      'price': 149.99,
      'pledged': false,
    },
  ];

  String sortBy = 'name';

  void addGift() async {
    final newGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(),
      ),
    );
    if (newGift != null) {
      setState(() {
        gifts.add(newGift);
      });
    }
  }

  void editGift(int index) async {
    final updatedGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(existingGift: gifts[index]),
      ),
    );
    if (updatedGift != null) {
      setState(() {
        gifts[index] = updatedGift;
      });
    }
  }

  void deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    gifts.sort((a, b) => a[sortBy].compareTo(b[sortBy]));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.eventName}'s Gift List",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
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
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
                  return Card(
                    color: gift['pledged'] ? Colors.red[100] : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(gift['name']),
                      subtitle: Text(
                        '${gift['category']} • ${gift['status']} • \$${gift['price'].toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            onPressed: gift['pledged'] ? null : () => editGift(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: gift['pledged'] ? null : () => deleteGift(index),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GiftDetailsPage(existingGift: gift),
                          ),
                        );
                      },
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
        label: const Text('Add New Gift'),
        onPressed: addGift,
      ),
    );
  }
}
