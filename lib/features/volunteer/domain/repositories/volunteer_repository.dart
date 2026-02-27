// Abstract repository interface for volunteer data
import '../models/volunteer_model.dart';
import '../models/dashboard_stats.dart';
import '../models/volunteer_activity.dart';

abstract class VolunteerRepository {
  // Get current logged-in volunteer's data
  Future<Volunteer?> getCurrentVolunteer();

  // Get volunteer by ID
  Future<Volunteer?> getVolunteerById(String volunteerId);

  // Update volunteer profile
  Future<bool> updateVolunteerProfile(Volunteer volunteer);

  // Get dashboard statistics for volunteer
  Future<DashboardStats?> getDashboardStats(String volunteerId);

  // Get volunteer's activities/history
  Future<List<VolunteerActivity>> getVolunteerActivities(String volunteerId);

  // Get upcoming opportunities
  Future<List<Map<String, dynamic>>> getUpcomingOpportunities(String volunteerId);

  // Mark activity as completed
  Future<bool> completeActivity(String activityId);
}
