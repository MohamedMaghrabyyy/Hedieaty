class GiftModel {
  final String id;
  final String name;
  final String description; // Gift description
  final String category;
  final double price; // Gift price
  final String userId; // User ID of the gift owner
  final String eventId; // Event ID associated with the gift
  final bool isPledged;
  final bool isPurchased;

  GiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.userId,
    required this.eventId,
    this.isPledged = false,
    this.isPurchased = false,
  });

  factory GiftModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return GiftModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      isPledged: map['isPledged'] ?? false,
      isPurchased: map['isPurchased'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'userId': userId,
      'eventId': eventId,
      'isPledged': isPledged,
      'isPurchased': isPurchased,
    };
  }

  // Helper function to determine the status of the gift
  String get status {
    if (!isPledged) {
      return 'available';
    } else if (isPledged && !isPurchased) {
      return 'pledged';
    } else {
      return 'purchased';
    }
  }
}
