import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/firestore_service.dart';

class CreateEventPage extends StatefulWidget {
  final String userId;

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
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: const Color.fromARGB(255, 80, 45, 140),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name Input with improved styling
              TextField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 16.0), // Space between fields

              // Event Description Input with improved styling
              TextField(
                controller: _eventDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
                maxLines: 3, // Allow multiline for the description
              ),
              const SizedBox(height: 16.0), // Space between fields

              // Event Location Input with improved styling
              TextField(
                controller: _eventLocationController,
                decoration: InputDecoration(
                  labelText: 'Event Location',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 16.0), // Space between fields

              // Event Date Picker with improved styling
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
                    style: TextStyle(
                      fontSize: 16.0,
                      color: _selectedDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0), // Space between fields

              // Create Button with improved styling
              Center( // Center the button horizontally
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: const Text(
                    'Create Event',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
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

      _firestoreService.createEvent(event).then((_) {
        // Once the event is successfully created, return to the event list page
        Navigator.pop(context);
      }).catchError((error) {
        // Handle any error in creating event
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create event.')),
        );
      });
    }
  }
}
