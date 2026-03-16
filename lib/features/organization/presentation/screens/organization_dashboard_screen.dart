import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:givv/features/organization/providers/dashboard_provider.dart';
import 'package:givv/features/organization/providers/event_provider.dart';
import 'package:givv/features/auth/providers/auth_providers.dart';
import '../../models/event_model.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_button.dart';
import 'package:intl/intl.dart';

class OrganizationDashboardScreen extends ConsumerStatefulWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  ConsumerState<OrganizationDashboardScreen> createState() => _OrganizationDashboardScreenState();
}

class _OrganizationDashboardScreenState extends ConsumerState<OrganizationDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final eventsAsync = userAsync.valueOrNull != null 
        ? ref.watch(eventsByOrganizerProvider(userAsync.valueOrNull!.uid))
        : const AsyncValue<List<Event>>.loading();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(statsAsync, userAsync, eventsAsync),
            _buildEvents(eventsAsync, context),
            _buildTeam(eventsAsync, statsAsync),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6794AA),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'DASH'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'EVENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'TEAM'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'PRO'),
        ],
        onTap: (index) {
          if (index == 3) {
            context.push('/profile');
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildDashboard(AsyncValue statsAsync, AsyncValue userAsync, AsyncValue<List<Event>> eventsAsync) {
    return SingleChildScrollView(
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
          _buildStatsOverview(statsAsync),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 32),
          const Text('Today\'s Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildImpactBanner(eventsAsync),
        ],
      ),
    );
  }

  Widget _buildImpactBanner(AsyncValue<List<Event>> eventsAsync) {
    final upcomingCount = eventsAsync.valueOrNull?.where((e) => e.computedStatus == EventStatus.upcoming).length ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6794AA), Color(0xFF4A6E81)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ready to change lives?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('You have $upcomingCount event(s) coming up. Verify tasks to award points!', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents(AsyncValue<List<Event>> eventsAsync, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Events Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Track and manage your community initiatives.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          eventsAsync.when(
            data: (events) {
              final upcoming = events.where((e) => e.computedStatus == EventStatus.upcoming).toList();
              final ongoing = events.where((e) => e.computedStatus == EventStatus.ongoing).toList();
              final past = events.where((e) => e.computedStatus == EventStatus.past).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Ongoing', ongoing, context),
                  const SizedBox(height: 24),
                  _buildSection('Upcoming', upcoming, context),
                  const SizedBox(height: 24),
                  _buildSection('Past', past, context),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Events error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam(AsyncValue<List<Event>> eventsAsync, AsyncValue statsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Team & Volunteers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Manage your growing community of helpers.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          statsAsync.when(
            data: (stats) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
              child: Row(
                children: [
                  _buildSimpleStat('Volunteers', stats.totalVolunteers.toString(), Icons.people),
                  const Spacer(),
                  _buildSimpleStat('Active Tasks', stats.totalTasks.toString(), Icons.assignment_turned_in),
                ],
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          eventsAsync.when(
            data: (events) {
              final pendingCount = events.fold(0, (sum, e) => sum + e.pendingRequests.length);
              if (pendingCount == 0) {
                return const Text('No pending requests found across your events.', style: TextStyle(color: Colors.grey));
              }
              return Column(
                children: events.where((e) => e.pendingRequests.isNotEmpty).map((e) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFFF0F9FF), child: Icon(Icons.person_add, color: Color(0xFF6794AA))),
                    title: Text('${e.pendingRequests.length} Requests for ${e.title}'),
                    subtitle: const Text('Pending approval'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/org-dashboard/event-details/${e.id}'),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Team error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6794AA)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatsOverview(AsyncValue statsAsync) {
    return statsAsync.when(
      data: (stats) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
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
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Stats error: $err'),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                label: 'Create Event',
                icon: Icons.add_circle_outline,
                backgroundColor: const Color(0xFF6794AA),
                iconColor: Colors.white,
                onPressed: () => context.push('/org-dashboard/create-event'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionButton(
                label: 'Leaderboard',
                icon: Icons.emoji_events_outlined,
                onPressed: () => context.push('/leaderboard'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Event> events, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const Text('No events in this category', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ...events.map((e) => _buildEventCard(e, context)).toList(),
      ],
    );
  }

  Widget _buildEventCard(Event event, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${DateFormat('MMM dd, yyyy').format(event.date)} • ${event.city}'),
            const SizedBox(height: 4),
            Text('${event.volunteersJoined.length} Joined', style: const TextStyle(color: Color(0xFF6794AA), fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/org-dashboard/event-details/${event.id}'),
      ),
    );
  }
}
