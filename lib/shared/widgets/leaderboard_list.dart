import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/volunteer/services/leaderboard_service.dart';
import '../../features/auth/models/user_model.dart';

final leaderboardStreamProvider = StreamProvider.family<List<GivvUser>, _LeaderboardParams>((ref, params) {
  final service = LeaderboardService();
  return service.getLeaderboardStream(
    filter: params.filter,
    orgId: params.orgId,
    city: params.city,
    state: params.state,
  );
});

class _LeaderboardParams {
  final LeaderboardFilter filter;
  final String? orgId;
  final String? city;
  final String? state;

  _LeaderboardParams({required this.filter, required this.orgId, required this.city, required this.state});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LeaderboardParams &&
          runtimeType == other.runtimeType &&
          filter == other.filter &&
          orgId == other.orgId &&
          city == other.city &&
          state == other.state;

  @override
  int get hashCode => filter.hashCode ^ orgId.hashCode ^ city.hashCode ^ state.hashCode;
}

class LeaderboardList extends ConsumerWidget {
  final LeaderboardFilter filter;
  final String? currentUserCity;
  final String? currentUserState;
  final String? orgId;

  const LeaderboardList({
    super.key,
    required this.filter,
    this.currentUserCity,
    this.currentUserState,
    this.orgId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = _LeaderboardParams(
      filter: filter,
      orgId: orgId,
      city: currentUserCity,
      state: currentUserState,
    );
    final leaderboardAsync = ref.watch(leaderboardStreamProvider(params));

    return leaderboardAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'No volunteers found in this category.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final rank = index + 1;
            return _buildLeaderboardTile(context, user, rank);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, GivvUser user, int rank) {
    final isTopThree = rank <= 3;
    final String locationLabel = filter == LeaderboardFilter.city
        ? user.city
        : filter == LeaderboardFilter.state
            ? (user.state ?? user.city)
            : '${user.city}, ${user.country}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: SizedBox(
          width: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isTopThree ? _getRankColor(rank) : Colors.blueGrey,
                ),
              ),
              if (user.profileImageUrl != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(user.profileImageUrl!),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.teal.shade50,
                  foregroundColor: Colors.teal,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'V',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          locationLabel,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user.points}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'pts',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.blueGrey.shade400;
    if (rank == 3) return Colors.brown.shade400;
    return Colors.grey;
  }
}
