import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';

class EditGiftPage extends StatefulWidget {
  final GiftModel gift; // Pass the existing gift to edit

  EditGiftPage({required this.gift});

  @override
  _EditGiftPageState createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditGiftPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String _selectedCategory = '';
  String _selectedStatus = '';
  double _price = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _descriptionController = TextEditingController(text: widget.gift.description);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _selectedCategory = widget.gift.category;
    _selectedStatus = widget.gift.status;
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      final updatedGift = GiftModel(
        id: widget.gift.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        status: _selectedStatus,
        isPledged: widget.gift.isPledged,
        eventId: widget.gift.eventId,
      );
      // Save the updated gift to the database (e.g., Firestore)
      // Your Firestore updating code goes here

      Navigator.pop(context); // Navigate back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Gift')),
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
