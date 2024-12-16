import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/models/gift_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    } catch (e) {
      print('Error fetching event by ID: $e');
    }
    return null;
  }
  // Create a new gift
  Future<void> createGift(GiftModel giftModel) async {
    try {
      DocumentReference docRef = await _firestore.collection('gifts').add(giftModel.toMap());
      print("Gift created with ID: ${docRef.id}");
    } catch (e) {
      print("Error creating gift: $e");
    }
  }

  // Update an existing gift by ID
  Future<void> updateGift(String giftId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('gifts').doc(giftId).update(updates);
      print("Gift updated with ID: $giftId");
    } catch (e) {
      print("Error updating gift: $e");
    }
  }

  // Delete a gift by ID
  Future<void> deleteGift(String giftId) async {
    try {
      await _firestore.collection('gifts').doc(giftId).delete();
      print("Gift deleted with ID: $giftId");
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }

  // Get all gifts
  Stream<List<GiftModel>> getAllGifts() {
    try {
      return _firestore.collection('gifts').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return GiftModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print("Error fetching gifts: $e");
      return const Stream.empty();
    }
  }

  // Fetch all gifts for a specific event
  Future<List<GiftModel>> getGiftsByEvent(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId) // Use 'eventId' for filtering
          .get();

      return snapshot.docs
          .map((doc) => GiftModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // Use 'fromMap'
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
