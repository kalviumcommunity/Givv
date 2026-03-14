import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/leaderboard_list.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../services/leaderboard_service.dart';

final leaderboardFilterProvider = StateProvider<LeaderboardFilter>((ref) => LeaderboardFilter.national);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(leaderboardFilterProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilterTabs(context, ref, currentFilter),
          Expanded(
            child: user == null 
                ? const Center(child: CircularProgressIndicator())
                : LeaderboardList(
                    filter: currentFilter,
                    currentUserCity: user.city,
                    currentUserState: user.state,
                    orgId: user.isOrgAdmin ? user.uid : user.organizationCode,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, WidgetRef ref, LeaderboardFilter currentFilter) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SegmentedButton<LeaderboardFilter>(
          segments: const [
            ButtonSegment(
              value: LeaderboardFilter.city,
              label: Text('City'),
              icon: Icon(Icons.location_city),
            ),
            ButtonSegment(
              value: LeaderboardFilter.state,
              label: Text('State'),
              icon: Icon(Icons.map),
            ),
            ButtonSegment(
              value: LeaderboardFilter.national,
              label: Text('National'),
              icon: Icon(Icons.public),
            ),
          ],
          selected: {currentFilter},
          onSelectionChanged: (Set<LeaderboardFilter> newSelection) {
            ref.read(leaderboardFilterProvider.notifier).state = newSelection.first;
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF6794AA);
              }
              return Colors.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.black87;
            }),
          ),
        ),
      ),
    );
  }
}
