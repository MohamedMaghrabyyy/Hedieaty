import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';

class CreateGiftPage extends StatefulWidget {
  final String eventId; // Pass the eventId to associate the gift with an event

  CreateGiftPage({required this.eventId});

  @override
  _CreateGiftPageState createState() => _CreateGiftPageState();
}

class _CreateGiftPageState extends State<CreateGiftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCategory = 'Electronics'; // Default category
  String _selectedStatus = 'available'; // Default status
  double _price = 0.0;

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      final gift = GiftModel(
        id: DateTime.now().toString(), // Unique ID for the new gift
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        status: _selectedStatus,
        isPledged: false, // Default is not pledged
        eventId: widget.eventId, // Use the passed eventId
      );
      // Save the gift to the database (e.g., Firestore)
      // Your Firestore saving code goes here

      Navigator.pop(context); // Navigate back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Gift')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Gift Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Books', 'Clothing', 'Toys']
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['available', 'pledged']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a status' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGift,
                child: Text('Save Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
