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
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
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
        title: const Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: const InputDecoration(labelText: 'Event Description'),
            ),
            TextField(
              controller: _eventLocationController,
              decoration: const InputDecoration(labelText: 'Event Location'),
            ),
            Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'Date: ${_selectedDate!.toLocal()}'
                      : 'No Date Chosen!',
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _saveEvent,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
