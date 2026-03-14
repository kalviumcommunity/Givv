import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart';

enum LeaderboardFilter {
  city,
  state,
  national
}

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Stream<List<GivvUser>> getLeaderboardStream({
    required LeaderboardFilter filter,
    required String? orgId,
    required String? city,
    required String? state,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'volunteer');

    if (orgId != null && orgId.isNotEmpty) {
      query = query.where('organizationCode', isEqualTo: orgId);
    }

    switch (filter) {
      case LeaderboardFilter.city:
        if (city != null) {
          query = query.where('city', isEqualTo: city);
        }
        break;
      case LeaderboardFilter.state:
        if (state != null) {
          query = query.where('state', isEqualTo: state);
        }
        break;
      case LeaderboardFilter.national:
        // No additional filters
        break;
    }

    return query
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GivvUser.fromFirestore(doc)).toList();
    });
  }

  Future<int> getUserRank(int userPoints) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'volunteer')
          .where('points', isGreaterThan: userPoints)
          .count()
          .get();
      return (snapshot.count ?? 0) + 1;
    } catch (e) {
      print('Error calculating user rank: $e');
      return -1;
    }
  }
}
