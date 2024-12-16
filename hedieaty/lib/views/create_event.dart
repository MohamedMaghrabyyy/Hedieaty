import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/firestore_service.dart';

class CreateEventPage extends StatefulWidget {
  final String userId; // Add userId as a final field

  // Modify the constructor to accept userId
  const CreateEventPage({super.key, required this.userId});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white), // Ensure icon color is white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _eventLocationController,
                decoration: const InputDecoration(
                  labelText: 'Event Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Pick a date'
                        : '${_selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveEvent() {
    if (widget.userId.isNotEmpty) {
      final event = EventModel(
        name: _eventNameController.text,
        description: _eventDescriptionController.text,
        location: _eventLocationController.text,
        date: _selectedDate!,
        userId: widget.userId, // Access userId through widget
      );

      _firestoreService.createEvent(event); // Firestore handles event ID generation
    }
  }
}
