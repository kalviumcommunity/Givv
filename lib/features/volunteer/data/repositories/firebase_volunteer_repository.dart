// Firebase implementation of VolunteerRepository
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/volunteer_model.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../domain/models/volunteer_activity.dart';
import '../../domain/repositories/volunteer_repository.dart';

class FirebaseVolunteerRepository implements VolunteerRepository {
  final FirebaseFirestore _firestore;

  FirebaseVolunteerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Volunteer?> getCurrentVolunteer() async {
    try {
      // Get from local storage or Firebase Auth
      // This would typically come from SharedPreferences or FirebaseAuth
      // For now, returning null - to be implemented with auth
      return null;
    } catch (e) {
      print('Error getting current volunteer: $e');
      return null;
    }
  }

  @override
  Future<Volunteer?> getVolunteerById(String volunteerId) async {
    try {
      final doc = await _firestore.collection('volunteers').doc(volunteerId).get();
      if (doc.exists) {
        return Volunteer.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting volunteer: $e');
      return null;
    }
  }

  @override
  Future<bool> updateVolunteerProfile(Volunteer volunteer) async {
    try {
      await _firestore
          .collection('volunteers')
          .doc(volunteer.id)
          .update(volunteer.toJson());
      return true;
    } catch (e) {
      print('Error updating volunteer profile: $e');
      return false;
    }
  }

  @override
  Future<DashboardStats?> getDashboardStats(String volunteerId) async {
    try {
      final doc = await _firestore.collection('volunteers').doc(volunteerId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return DashboardStats(
          totalHours: data['hoursContributed'] ?? 0,
          projectsCompleted: data['projectsCompleted'] ?? 0,
          rating: (data['rating'] ?? 0).toDouble(),
          certificationsEarned: (data['certifications'] as List?)?.length ?? 0,
          upcomingOpportunities: data['upcomingOpportunities'] ?? 0,
          impactLevel: _calculateImpactLevel(
            data['hoursContributed'] ?? 0,
            data['projectsCompleted'] ?? 0,
          ),
        );
      }
      return null;
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return null;
    }
  }

  @override
  Future<List<VolunteerActivity>> getVolunteerActivities(String volunteerId) async {
    try {
      final query = await _firestore
          .collection('activities')
          .where('volunteerId', isEqualTo: volunteerId)
          .orderBy('date', descending: true)
          .limit(20)
          .get();

      return query.docs
          .map((doc) => VolunteerActivity.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error getting volunteer activities: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUpcomingOpportunities(String volunteerId) async {
    try {
      final volunteer = await getVolunteerById(volunteerId);
      if (volunteer == null) return [];

      // Get opportunities that match volunteer's interests and skills
      final query = await _firestore
          .collection('opportunities')
          .where('status', isEqualTo: 'open')
          .orderBy('startDate', descending: false)
          .limit(10)
          .get();

      return query.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
    } catch (e) {
      print('Error getting upcoming opportunities: $e');
      return [];
    }
  }

  @override
  Future<bool> completeActivity(String activityId) async {
    try {
      await _firestore.collection('activities').doc(activityId).update({
        'status': 'completed',
      });
      return true;
    } catch (e) {
      print('Error completing activity: $e');
      return false;
    }
  }

  // Helper method to calculate impact level based on hours and projects
  String _calculateImpactLevel(int hours, int projects) {
    if (hours < 10 || projects < 1) {
      return 'Beginner';
    } else if (hours < 50 || projects < 5) {
      return 'Intermediate';
    } else if (hours < 100 || projects < 10) {
      return 'Advanced';
    } else {
      return 'Expert';
    }
  }
}
