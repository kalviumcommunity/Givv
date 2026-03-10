import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  Future<bool> createEvent(Event event) async {
    try {
      await _firestore.collection(_collection).doc(event.id).set(event.toJson());
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('organizerId', isEqualTo: organizerId)
          .get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching organizer events: $e');
      return [];
    }
  }

  Stream<List<Event>> streamEventsByOrganizer(String organizerId) {
    return _firestore
        .collection(_collection)
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  Future<List<Event>> getEventsByStatus(EventStatus status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.name)
          .get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching events by status: $e');
      return [];
    }
  }

  Future<List<Event>> getAllEvents() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching all events: $e');
      return [];
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Event.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching event by id: $e');
      return null;
    }
  }

  Future<bool> updateEvent(Event event) async {
    try {
      await _firestore.collection(_collection).doc(event.id).update(event.toJson());
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }
}
