class PledgeModel {
  final String userId;
  final String giftId;

  PledgeModel({required this.userId, required this.giftId});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'giftId': giftId,
    };
  }

  factory PledgeModel.fromMap(Map<String, dynamic> map) {
    return PledgeModel(
      userId: map['userId'],
      giftId: map['giftId'],
    );
  }
}
