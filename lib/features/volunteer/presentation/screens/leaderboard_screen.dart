import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/leaderboard_service.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_providers.dart';

final leaderboardServiceProvider = Provider((ref) => LeaderboardService());

final leaderboardProvider = FutureProvider.family<List<GivvUser>, String>((ref, filter) async {
  final service = ref.watch(leaderboardServiceProvider);
  final user = ref.watch(currentUserProvider).value;
  
  if (filter == 'City' && user?.city != null) {
    return service.getCityLeaderboard(user!.city);
  } else if (filter == 'State' && user?.state != null) {
    return service.getStateLeaderboard(user!.state!);
  }
  return service.getNationalLeaderboard();
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _filter = 'National';

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider(_filter));

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
          _buildFilterBar(),
          Expanded(
            child: leaderboardAsync.when(
              data: (users) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) => _buildLeaderboardTile(users[index], index + 1),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['City', 'State', 'National'].map((f) => ChoiceChip(
          label: Text(f),
          selected: _filter == f,
          onSelected: (val) => setState(() => _filter = f),
          selectedColor: const Color(0xFF6794AA),
          labelStyle: TextStyle(color: _filter == f ? Colors.white : Colors.black),
        )).toList(),
      ),
    );
  }

  Widget _buildLeaderboardTile(GivvUser user, int rank) {
    bool isTopThree = rank <= 3;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Center(
            child: isTopThree 
                ? Icon(Icons.emoji_events, color: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown)
                : Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${user.city}, ${user.country}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${user.points}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6794AA))),
            const Text('Points', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
