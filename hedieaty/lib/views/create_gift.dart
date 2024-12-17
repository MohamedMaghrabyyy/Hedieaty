import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/services/firestore_service.dart'; // Replace with your Firestore service class

class CreateGiftPage extends StatefulWidget {
  final String? eventId;

  CreateGiftPage({required this.eventId});

  @override
  _CreateGiftPageState createState() => _CreateGiftPageState();
}

class _CreateGiftPageState extends State<CreateGiftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(); // For category input

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      try {
        final gift = GiftModel(
          id: DateTime.now().toString(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(), // Category as string
          price: double.parse(_priceController.text.trim()),
          userId: 'current_user_id', // Replace with the current user's ID
          eventId: widget.eventId ?? '',
          isPledged: false, // Default value
          isPurchased: false, // Default value
        );

        // Save the gift to Firestore
        await FirestoreService().addGift(gift);

        // Navigate back after saving
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save gift: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Gift',
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
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16.0), // Space between fields

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
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                maxLines: 3, // Allow multi-line input for description
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16.0), // Space between fields

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
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16.0), // Space between fields

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
                validator: (value) => value == null || value.isEmpty ? 'Please enter a category' : null,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20.0), // Space before button

              // Save Button with improved styling
              Center( // Center the button horizontally
                child: ElevatedButton(
                  onPressed: _saveGift,
                  child: const Text(
                    'Save Gift',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // Button background color
                    foregroundColor: Colors.white, // Button text color
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Increased padding
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    minimumSize: const Size(200, 50), // Ensures the button is bigger (width, height)
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
