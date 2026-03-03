import '../models/organization_stats.dart';

class DashboardService {
  Future<OrganizationStats> fetchDashboardStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return OrganizationStats(
      totalVolunteers: 342,
      activeEvents: 12,
      totalTasks: 56,
      completionRate: 0.78,
    );
  }
}
