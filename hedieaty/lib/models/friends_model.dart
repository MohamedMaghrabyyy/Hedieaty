class Friend {
  final String userId1;  // The first user ID
  final String userId2;  // The second user ID

  // Constructor
  Friend({
    required this.userId1,
    required this.userId2,
  });

  // Convert a Friend object to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId1': userId1,
      'userId2': userId2,
    };
  }

  // Convert a Map to a Friend object (from Firestore)
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId1: map['userId1'],
      userId2: map['userId2'],
    );
  }
}
