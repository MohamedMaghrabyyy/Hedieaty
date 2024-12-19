import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/pledge_model.dart';
import 'package:hedieaty/models/friends_model.dart';
import 'package:hedieaty/models/notifications_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize _auth here


  // Method to create a notification
  Future<void> createNotification(String userId, String text) async {
    String notificationId = _firestore.collection('notifications').doc().id;

    await _firestore.collection('notifications').doc(notificationId).set({
      'userId': userId,
      'text': text,
    });
  }

  // Method to delete a notification (using String ID)
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
          .toList();

      if (notifications.isEmpty) {
        return [];
      }
      return notifications;
    });
  }


  // Get pledged gifts for the specified userId
  Stream<List<GiftModel>> streamPledgedGiftsForUser(String userId) {
    return _firestore
        .collection('pledges')
        .where('userId', isEqualTo: userId) // Search pledges by userId
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<GiftModel> pledgedGifts = [];

      print('Query snapshot received: ${querySnapshot.docs.length} pledges found.');

      // Fetch gift details for each pledge
      for (var doc in querySnapshot.docs) {
        PledgeModel pledge = PledgeModel.fromMap(doc.data());
        print('Fetching gift details for pledge with giftId: ${pledge.giftId}');

        // Get the gift details using the giftId from pledge
        var giftDoc = await _firestore.collection('gifts').doc(pledge.giftId).get();

        if (giftDoc.exists) {
          GiftModel gift = GiftModel.fromMap(giftDoc.data()!, id: giftDoc.id);
          pledgedGifts.add(gift);
        } else {
          print('Gift not found for giftId: ${pledge.giftId}');
        }
      }

      print('Pledged gifts fetched: ${pledgedGifts.length}');
      return pledgedGifts;
    });
  }




  Future<void> addFriend(String userId1, String userId2) async {
    // Create two entries to check friendship in both directions using FriendModel
    final friendData1 = FriendModel(userId1: userId1, userId2: userId2);
    final friendData2 = FriendModel(userId1: userId2, userId2: userId1);

    try {
      await FirebaseFirestore.instance.collection('friends').add(friendData1.toMap());
      await FirebaseFirestore.instance.collection('friends').add(friendData2.toMap());
    } catch (e) {
      print("Error adding friends: $e");
    }
  }

  Future<bool> areUsersFriends(String userId1, String userId2) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: userId1)
          .where('userId2', isEqualTo: userId2)
          .get();

      // Check for direct friendship (userId1 -> userId2)
      if (snapshot.docs.isNotEmpty) {
        return true;
      }

      // Check for reverse friendship (userId2 -> userId1)
      final reverseSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: userId2)
          .where('userId2', isEqualTo: userId1)
          .get();

      if (reverseSnapshot.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      print("Error checking friendship: $e");
      return false;
    }
  }



  // Save user data in Firestore with UID as document ID
  Future<void> saveUserData(UserModel userModel) async {
    try {
      await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
    } catch (e) {
      print("Error saving user data to Firestore: $e");
    }
  }

  // Get user data by UID
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("User not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
  // Function to get username by userId
  Future<String?> getUsernameById(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      // Check if the document exists and contains the name
      if (userDoc.exists) {
        final data = userDoc.data();
        return data?['name']; // Returning the username from Firestore
      } else {
        return null; // If the user document doesn't exist
      }
    } catch (e) {
      print("Error fetching username: $e");
      return null;
    }
  }
  // Method to get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Fetch current user data (userId should be passed)
  Future<Map<String, dynamic>> getCurrentUserData() async {
    final userId = _auth.currentUser?.uid; // Get the current logged-in user's ID
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()!;
  }

  // Update user profile (both name and email)
  Future<void> updateUserProfile(String name, String email) async {
    final userId = _auth.currentUser?.uid; // Get the current logged-in user's ID

    await _firestore.collection('users').doc(userId).update({
      'name': name,
      'email': email,
    });
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword); // Update password with Firebase Auth
    } else {
      throw Exception('No user logged in');
    }
  }

  // Create a new event
  Future<void> createEvent(EventModel event) async {
    try {
      await _firestore.collection('events').add({
        'name': event.name,
        'description': event.description,
        'location': event.location,
        'date': event.date,
        'userId': event.userId,
      });
      print('Event created successfully.');
    } catch (e) {
      print('Error creating event: $e');
    }
  }

  // Update an existing event by ID
  Future<void> updateEvent(String? eventId, EventModel updatedEvent) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'name': updatedEvent.name,
        'description': updatedEvent.description,
        'location': updatedEvent.location,
        'date': updatedEvent.date.toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete an event by ID
  Future<void> deleteEvent(String? eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      print("Event deleted with ID: $eventId");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  // Get all events
  Stream<List<EventModel>> getAllEvents() {
    try {
      return _firestore.collection('events').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print("Error fetching events: $e");
      return const Stream.empty();
    }
  }

  // Stream to fetch events for a specific user
  Stream<List<EventModel>> streamEventsForUser(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Fetch a specific event by its ID
  Future<EventModel?> getEventById(String? eventId) async {
    try {
      final docSnapshot = await _firestore.collection('events').doc(eventId).get();
      if (docSnapshot.exists) {
        return EventModel.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
      }
    } catch (e)      {
      print('Error fetching event by ID: $e');
    }
    return null;
  }

  Future<void> addGift(GiftModel gift) async {
    await FirebaseFirestore.instance.collection('gifts').add(gift.toMap());
  }

  Future<void> updateGift(String giftId, Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance.collection('gifts').doc(giftId).update(updatedData);
  }

  Future<void> deleteGift(String giftId) async {
    await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();
  }

  Stream<List<GiftModel>> streamGiftsForEvent(String? eventId) {
    return _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return GiftModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
    }).toList());
  }
  Stream<List<GiftModel>> streamGiftsForUser(String? userId) {
    return _firestore
        .collection('gifts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return GiftModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
    }).toList());
  }


  Future<GiftModel?> getGiftById(String giftId) async {
    final doc = await _firestore.collection('gifts').doc(giftId).get();
    if (doc.exists) {
      return GiftModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
    }
    return null;
  }

  Future<String> getUserNameById(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['name'] ?? 'Unknown User';
  }

  Future<void> createPledge(String userId, String giftId) async {
    try {
      await _firestore.collection('pledges').add({
        'userId': userId,
        'giftId': giftId,
        'pledgedAt': FieldValue.serverTimestamp(),
        // You can add other fields like due date or any other details as needed
      });
    } catch (e) {
      throw Exception('Error creating pledge: $e');
    }
  }

  Future<void> deletePledge(String userId, String giftId) async {
    final pledgeDocs = await FirebaseFirestore.instance
        .collection('pledges')
        .where('userId', isEqualTo: userId)
        .where('giftId', isEqualTo: giftId)
        .get();

    for (final doc in pledgeDocs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateGiftPledgeStatus(String giftId, bool isPledged) async {
    await _firestore.collection('gifts').doc(giftId).update({'isPledged': isPledged});
  }
  Future<String?> getPledgeOwner(String giftId) async {
    // Fetch the pledge document from Firestore
    final pledgeSnapshot = await FirebaseFirestore.instance
        .collection('pledges') // Assuming "pledges" is the correct collection
        .doc(giftId)           // Using giftId as the document ID
        .get();

    if (pledgeSnapshot.exists) {
      return pledgeSnapshot.data()?['userId'] as String?; // Return the 'userId' field
    }

    return null; // No pledge found
  }

  Future<void> updateGiftPurchaseStatus(String giftId, bool isPurchased) async {
    await _firestore.collection('gifts').doc(giftId).update({'isPurchased': isPurchased});
  }

  // Check if a user has already pledged a gift
  Future<bool> isGiftPledgedByUser(String userId, String giftId) async {
    final querySnapshot = await _firestore
        .collection('pledges')
        .where('userId', isEqualTo: userId)
        .where('giftId', isEqualTo: giftId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Get the gift creator's userId
  Future<String> getGiftCreatorId(String? giftId) async {
    final giftDoc = await _firestore.collection('gifts').doc(giftId).get();
    return giftDoc['userId']; // Assuming the 'userId' field stores the creator's ID
  }

  // Stream pledged gifts for a user
  Stream<List<PledgeModel>> streamPledgesForGift(String giftId) {
    return _firestore
        .collection('pledges')
        .where('giftId', isEqualTo: giftId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PledgeModel.fromMap(doc.data()))
        .toList());
  }
  // Delete event and all associated gifts based on eventId
  Future<void> deleteEventAndGifts(String? eventId) async {
    try {
      // Start a batch operation to delete the gifts and the event atomically
      WriteBatch batch = _firestore.batch();

      // Reference to the gifts collection
      final giftCollection = _firestore.collection('gifts');

      // Fetch all the gifts associated with this eventId
      final giftSnapshot = await giftCollection.where('eventId', isEqualTo: eventId).get();

      // Add delete operations for each gift document to the batch
      for (var giftDoc in giftSnapshot.docs) {
        batch.delete(giftDoc.reference);  // Deleting each gift document
      }

      // After deleting the gifts, delete the event itself
      batch.delete(_firestore.collection('events').doc(eventId));  // Deleting the event document

      // Commit the batch operation to Firestore
      await batch.commit();

      print("Event and associated gifts deleted successfully.");
    } catch (e) {
      print("Error deleting event and gifts: $e");
      throw Exception("Failed to delete event and gifts.");
    }
  }

}
