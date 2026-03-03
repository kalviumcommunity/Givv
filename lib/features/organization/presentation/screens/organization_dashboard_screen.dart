import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:givv/features/organization/providers/dashboard_provider.dart';
import 'package:givv/features/auth/providers/auth_providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/volunteer_list_item.dart';

class OrganizationDashboardScreen extends ConsumerWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  organizationName: userAsync.valueOrNull?.organizationName ?? userAsync.valueOrNull?.name ?? 'Organization',
                  role: 'Organization Admin',
                  onSignOut: () async {
                    final repo = ref.read(authRepositoryProvider);
                    await repo.signOut();
                    if (context.mounted) context.go('/select-role');
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    DropdownButton<String>(
                      value: 'Last 30 days',
                      underline: const SizedBox(),
                      items: ['Last 7 days', 'Last 30 days', 'Last Year']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.blueGrey,
                                      ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      title: 'Total Volunteers',
                      value: stats.totalVolunteers.toString(),
                      icon: Icons.people_outline,
                      iconColor: Colors.blue,
                      backgroundColor: const Color(0xFFEFF6FF),
                    ),
                    StatCard(
                      title: 'Active Events',
                      value: stats.activeEvents.toString(),
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.green,
                      backgroundColor: const Color(0xFFF0FDF4),
                    ),
                    StatCard(
                      title: 'Total Tasks',
                      value: stats.totalTasks.toString(),
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.orange,
                      backgroundColor: const Color(0xFFFFF7ED),
                    ),
                    StatCard(
                      title: 'Completion Rate',
                      value: '${(stats.completionRate * 100).toInt()}%',
                      icon: Icons.speed_outlined,
                      iconColor: Colors.purple,
                      backgroundColor: const Color(0xFFFAF5FF),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Volunteers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Full list'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      VolunteerListItem(
                        rank: 1,
                        name: 'Sarah J.',
                        projects: '12 Projects',
                        points: '1,250',
                        imageUrl: 'https://i.pravatar.cc/150?u=sarah',
                      ),
                      Divider(),
                      VolunteerListItem(
                        rank: 2,
                        name: 'Mike D.',
                        projects: '9 Projects',
                        points: '1,100',
                        imageUrl: 'https://i.pravatar.cc/150?u=mike',
                      ),
                      Divider(),
                      VolunteerListItem(
                        rank: 3,
                        name: 'Elena R.',
                        projects: '8 Projects',
                        points: '950',
                        imageUrl: 'https://i.pravatar.cc/150?u=elena',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    QuickActionButton(
                      label: 'Create Event',
                      icon: Icons.add_circle_outline,
                      backgroundColor: const Color(0xFF62929E),
                      iconColor: Colors.white,
                      onPressed: () {
                        context.push('/org-dashboard/create-event');
                      },
                    ),
                    QuickActionButton(
                      label: 'Volunteers',
                      icon: Icons.group_outlined,
                      onPressed: () {},
                    ),
                    QuickActionButton(
                      label: 'Leaderboard',
                      icon: Icons.emoji_events_outlined,
                      onPressed: () {},
                    ),
                    QuickActionButton(
                      label: 'Reports',
                      icon: Icons.analytics_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'DASH'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'EVENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'TEAM'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'SET'),
        ],
      ),
    );
  }
}
