import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';
import '../../models/join_request_model.dart';
import '../../providers/request_provider.dart';
import '../../providers/event_provider.dart';
import '../../../volunteer/services/point_service.dart';

class VolunteerManagementTab extends ConsumerWidget {
  final Event event;

  const VolunteerManagementTab({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(eventRequestsProvider(event.id));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pending Requests'),
          const SizedBox(height: 12),
          requestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No pending requests', style: TextStyle(color: Colors.grey))),
                );
              }
              return Column(
                children: requests.map((req) => _buildRequestCard(context, ref, req)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Joined Volunteers (${event.volunteersJoined.length})'),
          const SizedBox(height: 12),
          if (event.volunteersJoined.isEmpty)
            const Center(child: Text('No volunteers joined yet', style: TextStyle(color: Colors.grey)))
          else
            Expanded(
              child: ListView.builder(
                itemCount: event.volunteersJoined.length,
                itemBuilder: (context, index) {
                  final volunteerId = event.volunteersJoined[index];
                  return _buildVolunteerTile(volunteerId);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRequestCard(BuildContext context, WidgetRef ref, JoinRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: request.userImageUrl != null ? NetworkImage(request.userImageUrl!) : null,
          child: request.userImageUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
        ),
        title: Text(request.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Wants to join this event'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _handleRequest(ref, request, true),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _handleRequest(ref, request, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerTile(String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey[50],
          child: const Icon(Icons.person_outline, color: Color(0xFF6794AA)),
        ),
        title: Text('Volunteer $userId'), // Ideally fetch name
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // View profile logic
        },
      ),
    );
  }

  Future<void> _handleRequest(WidgetRef ref, JoinRequest request, bool approved) async {
    final status = approved ? RequestStatus.accepted : RequestStatus.rejected;
    final success = await ref.read(joinRequestProvider.notifier).updateStatus(request.id, status);
    
    if (success && approved) {
      // Update event joined list
      final currentEvent = await ref.read(eventServiceProvider).getEventById(request.eventId);
      if (currentEvent != null) {
        final updatedVolunteers = List<String>.from(currentEvent.volunteersJoined)..add(request.userId);
        final eventSuccess = await ref.read(eventProvider.notifier).updateEvent(currentEvent.copyWith(volunteersJoined: updatedVolunteers));
        if (eventSuccess) {
          await PointService().awardPointsForJoinEvent(request.userId);
        }
      }
    }
  }
}
