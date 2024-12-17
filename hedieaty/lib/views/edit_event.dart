import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_service.dart';
import 'package:hedieaty/models/event_model.dart';

class EditEventPage extends StatefulWidget {
  final String? eventId;

  EditEventPage({required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _eventLocationController =
      TextEditingController();
  DateTime? _selectedDate; // This will store the selected date
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  // Load the event details from Firestore using the eventId
  Future<void> _loadEvent() async {
    final event = await _firestoreService.getEventById(widget.eventId);
    if (event != null) {
      _eventNameController.text = event.name;
      _eventDescriptionController.text = event.description;
      _eventLocationController.text = event.location;
      _selectedDate = event.date; // Set the selected date for the event
    }
  }

  // Save the updated event details
  void _saveEvent() {
    if (_selectedDate != null) {
      final updatedEvent = EventModel(
        id: widget.eventId,
        name: _eventNameController.text,
        description: _eventDescriptionController.text,
        location: _eventLocationController.text,
        date: _selectedDate!,
        userId: '', // Set this if needed, or keep as is
      );

      // Update the event in Firestore
      _firestoreService.updateEvent(widget.eventId, updatedEvent);
      Navigator.pop(context); // Go back after saving
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Event',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme:
            const IconThemeData(color: Colors.white), // Set icon color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added scrolling for better UI on small screens
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align widgets to the left
            children: [
              // Event Name Field
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16), // Space between fields

              // Event Description Field
              TextField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 4, // Allow multiline for the description
              ),
              const SizedBox(height: 16), // Space between fields

              // Event Location Field
              TextField(
                controller: _eventLocationController,
                decoration: const InputDecoration(
                  labelText: 'Event Location',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16), // Space between fields

              // Date Picker Row
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribute space
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Date: ${_selectedDate!.toLocal()}'
                        : 'No Date Chosen!',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                    color: Colors.deepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 16), // Space between fields

              Center( // Center the button horizontally
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: const Text(
                    'Save Event',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Button color
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Increased padding
                    textStyle: const TextStyle(
                      fontSize: 18, // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                    minimumSize: const Size(200, 50), // Ensures the button is bigger (width, height)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
