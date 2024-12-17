import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/services/firestore_service.dart';

class EditGiftPage extends StatefulWidget {
  final String giftId;
  final GiftModel gift;

  EditGiftPage({required this.giftId, required this.gift});

  @override
  _EditGiftPageState createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditGiftPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _descriptionController = TextEditingController(text: widget.gift.description);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _categoryController = TextEditingController(text: widget.gift.category);
  }

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new GiftModel instance with the updated fields
        final updatedGift = GiftModel(
          id: widget.giftId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          userId: widget.gift.userId, // Retain the original userId
          eventId: widget.gift.eventId, // Retain the original eventId
          isPledged: widget.gift.isPledged,
          isPurchased: widget.gift.isPurchased,
        );

        // Update the gift in Firestore
        await FirestoreService().updateGift(widget.giftId, updatedGift.toMap());

        // Navigate back after saving
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update gift: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Gift',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: const Color.fromARGB(255, 80, 45, 140),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Gift Name Input with improved styling
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Gift Name',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a name' : null,
                readOnly: widget.gift.isPledged, // Prevent edits for pledged gifts
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16), // Space between fields

              // Gift Description Input with improved styling
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a description' : null,
                readOnly: widget.gift.isPledged,
                maxLines: 3, // Allow multi-line input for description
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16), // Space between fields

              // Gift Price Input with improved styling
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                readOnly: widget.gift.isPledged,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16), // Space between fields

              // Category Input with improved styling
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a category' : null,
                readOnly: widget.gift.isPledged,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20), // Space before the button

              // Save Button with improved styling
              Center( // Center the button horizontally
                child: ElevatedButton(
                  onPressed: widget.gift.isPledged ? null : _saveGift,
                  child: const Text(
                    'Save Gift',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    minimumSize: const Size(200, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
