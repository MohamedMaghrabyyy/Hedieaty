import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  String name;
  String description;
  String location;
  DateTime date; // This will store the DateTime object
  String userId;

  EventModel({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.userId,
  });

  // From Firestore (using fromMap instead of fromFirestore)
  factory EventModel.fromMap(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      name: data['name'],
      description: data['description'],
      location: data['location'],
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()  // Convert Timestamp to DateTime
          : DateTime.parse(data['date']), // Convert String to DateTime if it's a String
      userId: data['userId'],
    );
  }

  // To Firestore (existing method)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      'userId': userId,
    };
  }
}
