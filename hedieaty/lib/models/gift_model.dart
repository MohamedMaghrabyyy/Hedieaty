class GiftModel {
  final String id; // Unique gift ID
  final String name; // Gift name
  final String description; // Gift description
  final String category; // Gift category (e.g., electronics, books)
  final double price; // Gift price
  final String status; // Status of the gift (e.g., available, pledged)
  final bool isPledged; // Whether the gift is pledged or not
  final String eventId; // ID of the associated event

  GiftModel({
    required this.id, // Add id as a required parameter
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.isPledged,
    required this.eventId,
  });

  // Convert GiftModel to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'isPledged': isPledged,
      'eventId': eventId,
    };
  }

  // Convert Firestore document to GiftModel
  factory GiftModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GiftModel(
      id: documentId, // Assign the Firestore document ID
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'available', // Default status as 'available'
      isPledged: map['isPledged'] ?? false, // Default to false if not present
      eventId: map['eventId'] ?? '',
    );
  }
}
