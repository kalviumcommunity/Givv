import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../organization/models/event_model.dart';
import '../../data/repositories/volunteer_repository.dart';
import 'package:intl/intl.dart';
import 'my_events_screen.dart';
import '../../../auth/presentation/profile_screen.dart';
import '../../services/leaderboard_service.dart';

final userRankProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return -1;
  return LeaderboardService().getUserRank(user.points);
});

final nearbyEventsProvider = FutureProvider<List<Event>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return VolunteerRepository().getNearbyEvents(user.city);
});

final discoverEventsProvider = FutureProvider<List<Event>>((ref) async {
  return VolunteerRepository().getAllUpcomingEvents();
});

class VolunteerDashboardScreen extends ConsumerStatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  ConsumerState<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends ConsumerState<VolunteerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) return const Center(child: Text('User not found'));
            return IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashView(context, user, ref),
                _buildDiscoverView(context),
                const MyEventsScreen(isTab: true),
                const ProfileScreen(isTab: true),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6794AA),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'DASH'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'DISCOVER'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'MY EVENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDashView(BuildContext context, dynamic user, WidgetRef ref) {
    final nearbyEventsAsync = ref.watch(nearbyEventsProvider);
    final rankAsync = ref.watch(userRankProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, user),
          const SizedBox(height: 24),
          _buildStatsGrid(user, rankAsync),
          const SizedBox(height: 32),
          _buildQuickAccess(context),
          const SizedBox(height: 32),
          _buildNearbyEvents(context, nearbyEventsAsync),
        ],
      ),
    );
  }

  Widget _buildDiscoverView(BuildContext context) {
    final allEventsAsync = ref.watch(discoverEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Discover Opportunities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Find ways to contribute beyond your local area.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          allEventsAsync.when(
            data: (events) {
              if (events.isEmpty) return const Center(child: Text('No upcoming events found.'));
              return Column(
                children: events.map((e) => _buildDiscoveryCard(context, e)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.name ?? "Volunteer"}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${user?.city}, ${user?.country}', style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
        IconButton(
          onPressed: () async {
            final repo = ref.read(authRepositoryProvider);
            await repo.signOut();
            if (context.mounted) context.go('/select-role');
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(dynamic user, AsyncValue<int> rankAsync) {
    final rankText = rankAsync.when(
      data: (r) => r == -1 ? 'N/A' : '#$r',
      loading: () => '...',
      error: (_, __) => 'N/A',
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Points', '${user?.points ?? 0}', Icons.star_border, Colors.amber),
        _buildStatCard('Events Joined', '${user?.eventsJoined ?? 0}', Icons.event_available, Colors.blue),
        _buildStatCard('Tasks Done', '${user?.tasksCompleted ?? 0}', Icons.task_alt, Colors.green),
        _buildStatCard('Global Rank', rankText, Icons.leaderboard_outlined, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Row(
      children: [
        _buildQuickCircle(context, 'Leaderboard', Icons.emoji_events_outlined, '/leaderboard'),
        _buildQuickCircle(context, 'My Tasks', Icons.assignment_outlined, '/volunteer-dashboard/my-tasks'),
        _buildQuickCircle(context, 'Certificates', Icons.workspace_premium_outlined, '/profile'),
      ],
    );
  }

  Widget _buildQuickCircle(BuildContext context, String label, IconData icon, String route) {
    return Expanded(
      child: InkWell(
        onTap: () => context.push(route),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFF6794AA)),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyEvents(BuildContext context, AsyncValue<List<Event>> nearbyEventsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nearby Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        nearbyEventsAsync.when(
          data: (events) {
            if (events.isEmpty) return const Text('No events found near you.', style: TextStyle(color: Colors.grey));
            return Column(
              children: events.map((e) => _buildDiscoveryCard(context, e)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(BuildContext context, Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[100]!)),
      child: InkWell(
        onTap: () => context.push('/volunteer-dashboard/event-details/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(20)),
                    child: Text(event.category, style: const TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  const Icon(Icons.location_on, size: 14, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text(event.city, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(DateFormat('MMM dd, yyyy').format(event.date), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const Spacer(),
                  Text('${event.volunteersJoined.length} / ${event.maxVolunteers} Vol.', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6794AA))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
