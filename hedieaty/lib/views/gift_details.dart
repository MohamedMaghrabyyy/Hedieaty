import 'package:flutter/material.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? existingGift;

  const GiftDetailsPage({Key? key, this.existingGift}) : super(key: key);

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String category;
  late double price;
  late String description;
  late bool pledged;

  @override
  void initState() {
    super.initState();
    name = widget.existingGift?['name'] ?? '';
    category = widget.existingGift?['category'] ?? 'Electronics';
    price = widget.existingGift?['price'] ?? 0.0;
    description = widget.existingGift?['description'] ?? '';
    pledged = widget.existingGift?['pledged'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingGift == null ? 'Add Gift' : 'Edit Gift'),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                onSaved: (value) => name = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a gift name' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                  DropdownMenuItem(value: 'Books', child: Text('Books')),
                  DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
                ],
                onChanged: (value) => category = value!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => price = double.parse(value!),
                validator: (value) =>
                double.tryParse(value!) == null ? 'Enter a valid price' : null,
              ),
              SwitchListTile(
                value: pledged,
                title: const Text('Pledged'),
                onChanged: widget.existingGift?['pledged'] == true
                    ? null
                    : (value) => setState(() => pledged = value),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'name': name,
                      'description': description,
                      'category': category,
                      'price': price,
                      'pledged': pledged,
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
