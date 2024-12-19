class NotificationModel {
  final String id;        // String ID for the notification
  final String userId;
  final String text;

  NotificationModel({
    required this.id,       // Initialize the id
    required this.userId,
    required this.text,
  });

  // Factory method to create NotificationModel from Firestore document data
  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,                // Use the provided id
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
    );
  }

  // Method to convert NotificationModel to Firestore document data
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
    };
  }
}
