import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../organization/models/event_model.dart';
import '../../data/repositories/volunteer_repository.dart';

final volunteerRepoProvider = Provider((ref) => VolunteerRepository());

final myEventsProvider = FutureProvider<List<Event>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return ref.watch(volunteerRepoProvider).getMyEvents(user.uid);
});

class MyEventsScreen extends ConsumerWidget {
  final bool isTab;
  const MyEventsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(myEventsProvider);

    final content = eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyState();
        }
        final upcoming = events.where((e) => e.computedStatus == EventStatus.upcoming).toList();
        final ongoing = events.where((e) => e.computedStatus == EventStatus.ongoing).toList();
        final past = events.where((e) => e.computedStatus == EventStatus.past).toList();

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                labelColor: Color(0xFF6794AA),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF6794AA),
                tabs: [
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildEventList(ongoing, context),
                    _buildEventList(upcoming, context),
                    _buildEventList(past, context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );

    if (isTab) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('My Committments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Events', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: content,
    );
  }

  Widget _buildEventList(List<Event> events, BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('No events in this category', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventCard(events[index], context),
    );
  }

  Widget _buildEventCard(Event event, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${DateFormat('MMM dd').format(event.date)} • ${event.city}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/volunteer-dashboard/event-details/${event.id}'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('You haven\'t joined any events yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
