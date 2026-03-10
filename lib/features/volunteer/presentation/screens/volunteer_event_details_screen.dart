import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../organization/models/event_model.dart';
import '../../../organization/providers/event_provider.dart';
import '../../../organization/providers/request_provider.dart';
import '../../../organization/models/join_request_model.dart';
import '../../../organization/presentation/widgets/event_info_card.dart';
import '../../../volunteer/services/point_service.dart';

class VolunteerEventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const VolunteerEventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Event Details', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) return const Center(child: Text('Event not found'));
          
          final isJoined = event.volunteersJoined.contains(user?.uid);
          final isPending = event.pendingRequests.contains(user?.uid);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                EventInfoCard(event: event),
                const SizedBox(height: 24),
                if (isJoined)
                  _buildStatusBanner('You are joined in this event!', Colors.green)
                else if (isPending)
                  _buildStatusBanner('Your join request is pending approval.', Colors.orange)
                else
                  _buildJoinButton(context, ref, event, user?.uid),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
    );
  }

  Widget _buildJoinButton(BuildContext context, WidgetRef ref, Event event, String? userId) {
    if (userId == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _handleJoin(context, ref, event, userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6794AA),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          event.joinType == JoinType.open ? 'Join Event' : 'Request to Join',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleJoin(BuildContext context, WidgetRef ref, Event event, String userId) async {
    if (event.joinType == JoinType.open) {
      final updatedVolunteers = List<String>.from(event.volunteersJoined)..add(userId);
      final success = await ref.read(eventProvider.notifier).updateEvent(event.copyWith(volunteersJoined: updatedVolunteers));
      if (success) {
        await PointService().awardPointsForJoinEvent(userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined successfully! +10 Points'), backgroundColor: Colors.green));
        }
      }
    } else {
      final request = JoinRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: event.id,
        userId: userId,
        userName: ref.read(currentUserProvider).value?.name ?? 'Unknown',
        timestamp: DateTime.now(),
      );
      await ref.read(joinRequestServiceProvider).createJoinRequest(request);
      
      // Update event pending list
      final updatedPending = List<String>.from(event.pendingRequests)..add(userId);
      await ref.read(eventProvider.notifier).updateEvent(event.copyWith(pendingRequests: updatedPending));
    }
  }
}
