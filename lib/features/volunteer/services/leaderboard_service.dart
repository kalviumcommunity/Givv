import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<List<GivvUser>> getNationalLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'volunteer')
          .orderBy('points', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => GivvUser.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching national leaderboard: $e');
      return [];
    }
  }

  Future<List<GivvUser>> getStateLeaderboard(String state, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'volunteer')
          .where('state', isEqualTo: state)
          .orderBy('points', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => GivvUser.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching state leaderboard: $e');
      return [];
    }
  }

  Future<List<GivvUser>> getCityLeaderboard(String city, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'volunteer')
          .where('city', isEqualTo: city)
          .orderBy('points', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => GivvUser.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching city leaderboard: $e');
      return [];
    }
  }
}
