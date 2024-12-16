class GiftModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final bool isPledged;
  final String? eventId;

  GiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.isPledged,
    required this.eventId,
  });

  // Convert Firestore data to a GiftModel instance
  static GiftModel fromMap(Map<String, dynamic> map, String id) {
    return GiftModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num).toDouble(),
      status: map['status'] ?? 'available',
      isPledged: map['isPledged'] ?? false,
      eventId: map['eventId'] ?? '',
    );
  }

  // Convert GiftModel instance to a Map
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
}
