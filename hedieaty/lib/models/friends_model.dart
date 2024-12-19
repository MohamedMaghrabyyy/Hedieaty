class FriendModel {
  final String userId1;
  final String userId2;

  FriendModel({
    required this.userId1,
    required this.userId2,
  });

  // Convert to a map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId1': userId1,
      'userId2': userId2,
    };
  }

  // Create a FriendModel from Firestore document
  factory FriendModel.fromMap(Map<String, dynamic> map) {
    return FriendModel(
      userId1: map['userId1'] as String,
      userId2: map['userId2'] as String,
    );
  }
}
