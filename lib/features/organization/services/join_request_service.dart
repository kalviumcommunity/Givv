import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/join_request_model.dart';

class JoinRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'joinRequests';

  Future<bool> createJoinRequest(JoinRequest request) async {
    try {
      await _firestore.collection(_collection).doc(request.id).set(request.toJson());
      return true;
    } catch (e) {
      print('Error creating join request: $e');
      return false;
    }
  }

  Stream<List<JoinRequest>> streamRequestsByEvent(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JoinRequest.fromJson(doc.data())).toList());
  }

  Future<bool> updateRequestStatus(String requestId, RequestStatus status) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': status.name,
      });
      return true;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }

  Future<bool> hasAlreadyRequested(String userId, String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing request: $e');
      return false;
    }
  }
}
