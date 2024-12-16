import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/firestore_service.dart';

class EditEventPage extends StatefulWidget {
  final EventModel? existingEvent;

  const EditEventPage({super.key, this.existingEvent});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      _nameController.text = widget.existingEvent!.name;
      _descriptionController.text = widget.existingEvent!.description;
      _locationController.text = widget.existingEvent!.location;
      _dateController.text = widget.existingEvent!.date.toLocal().toString().split(' ')[0];
    }
  }

  void saveEvent() async {
    final updatedEvent = EventModel(
      id: widget.existingEvent?.id ?? DateTime.now().toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      date: DateTime.parse(_dateController.text),
      userId: 'currentUserId', // You may want to fetch this dynamically
    );

    // Call updateEvent with id and the updated EventModel
    await _firestoreService.updateEvent(updatedEvent.id, updatedEvent);

    Navigator.pop(context, updatedEvent);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveEvent,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
