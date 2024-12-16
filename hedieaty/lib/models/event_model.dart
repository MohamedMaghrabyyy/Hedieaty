class EventModel {
  final String id; // Unique event ID
  final String name; // Event name
  final DateTime date; // Event date
  final String location; // Event location
  final String description; // Event description
  final String userId; // ID of the user who created the event

  EventModel({
    required this.id, // Make ID required
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
  });

  // Convert EventModel to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(), // Store date as ISO string
      'location': location,
      'description': description,
      'userId': userId,
    };
  }

  // Convert Firestore document to EventModel
  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      id: documentId, // Use the Firestore document ID as the event ID
      name: map['name'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}
