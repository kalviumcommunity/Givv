import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';
import '../models/organization_stats.dart';
import '../../auth/providers/auth_providers.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardStatsProvider = FutureProvider<OrganizationStats>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    return OrganizationStats(totalVolunteers: 0, activeEvents: 0, totalTasks: 0, completionRate: 0);
  }
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.fetchDashboardStats(user.uid);
});
