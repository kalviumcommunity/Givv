import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';
import '../models/organization_stats.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardStatsProvider = FutureProvider<OrganizationStats>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.fetchDashboardStats();
});
