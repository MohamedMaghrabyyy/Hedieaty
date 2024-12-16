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

  String _selectedCategory = '';
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _descriptionController = TextEditingController(text: widget.gift.description);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _selectedCategory = widget.gift.category;
    _selectedStatus = widget.gift.status;
  }

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new GiftModel instance with the updated fields
        final updatedGift = GiftModel(
          id: widget.giftId, // Explicitly set the gift ID
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          price: double.parse(_priceController.text.trim()),
          status: _selectedStatus,
          isPledged: widget.gift.isPledged,
          eventId: widget.gift.eventId,
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
      appBar: AppBar(title: const Text('Edit Gift')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a name' : null,
                readOnly: widget.gift.isPledged, // Prevent edits for pledged gifts
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a description' : null,
                readOnly: widget.gift.isPledged,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
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
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Books', 'Clothing', 'Toys']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: widget.gift.isPledged
                    ? null // Disable dropdown for pledged gifts
                    : (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['available', 'pledged']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: widget.gift.isPledged
                    ? null
                    : (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.gift.isPledged ? null : _saveGift,
                child: const Text('Save Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
