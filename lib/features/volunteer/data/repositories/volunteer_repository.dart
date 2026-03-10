import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/volunteer_model.dart';
import '../../../organization/models/event_model.dart';

class VolunteerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Event>> getNearbyEvents(String city) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('city', isEqualTo: city)
          .where('status', isEqualTo: EventStatus.upcoming.name)
          .get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching nearby events: $e');
      return [];
    }
  }

  Future<List<Event>> getMyEvents(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('volunteersJoined', arrayContains: userId)
          .get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching my events: $e');
      return [];
    }
  }

  Future<List<Event>> getAllUpcomingEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: EventStatus.upcoming.name)
          .orderBy('date', descending: false)
          .get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching all upcoming events: $e');
      return [];
    }
  }
}
