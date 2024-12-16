class EventModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final String userId;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.userId,
  });

  // Factory constructor to create an EventModel from a map (useful for Firebase data)
  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      name: map['name'],
      description: map['description'],
      location: map['location'],
      date: DateTime.parse(map['date']),
      userId: map['userId'],
    );
  }

  // Method to convert the model to a map (useful for saving to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}
