import 'package:cloud_firestore/cloud_firestore.dart';

class PointService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  static const int pointsJoinEvent = 10;
  static const int pointsCompleteTask = 20;
  static const int pointsVerifiedProof = 10;
  static const int pointsAttendFullEvent = 30;
  static const int pointsLeadTeam = 40;

  Future<void> awardPoints(String userId, int points, String reason) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;

        final currentPoints = snapshot.data()?['points'] ?? 0;
        transaction.update(userRef, {
          'points': currentPoints + points,
        });

        // Log point history (optional but good for tracking)
        final historyRef = userRef.collection('pointHistory').doc();
        transaction.set(historyRef, {
          'points': points,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error awarding points: $e');
    }
  }

  Future<void> awardPointsForJoinEvent(String userId) async {
    await awardPoints(userId, pointsJoinEvent, 'Joined Event');
  }

  Future<void> awardPointsForTaskVerification(String userId) async {
    // Complete Task + Verified Proof
    await awardPoints(userId, pointsCompleteTask + pointsVerifiedProof, 'Task Verified');
  }
}
