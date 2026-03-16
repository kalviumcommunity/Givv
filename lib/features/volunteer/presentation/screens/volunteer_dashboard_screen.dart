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
  String _filterLevel = 'World'; // 'District', 'State', 'Country', 'World'
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Discover Opportunities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Find ways to contribute beyond your local area.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: allEventsAsync.when(
            data: (events) {
              // Extract unique locations from events
              final countries = events.map((e) => e.country).where((c) => c.isNotEmpty).toSet().toList()..sort();
              final states = events
                  .where((e) => _selectedCountry == null || e.country == _selectedCountry)
                  .map((e) => e.state)
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                  ..sort();
              final cities = events
                  .where((e) => (_selectedCountry == null || e.country == _selectedCountry) && 
                                (_selectedState == null || e.state == _selectedState))
                  .map((e) => e.city)
                  .where((c) => c.isNotEmpty)
                  .toSet()
                  .toList()
                  ..sort();

              // Filtering logic
              final filteredEvents = events.where((e) {
                bool matches = true;
                if (_selectedCountry != null) matches &= (e.country == _selectedCountry);
                if (_selectedState != null) matches &= (e.state == _selectedState);
                if (_selectedCity != null) matches &= (e.city == _selectedCity);
                return matches;
              }).toList();

              return Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLocationFilters(countries, states, cities),
                  Expanded(
                    child: filteredEvents.isEmpty
                        ? _buildEmptyDiscoverState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, index) => _buildDiscoveryCard(context, filteredEvents[index]),
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilters(List<String> countries, List<String> states, List<String> cities) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildFilterDropdown(
                hint: 'Country',
                value: _selectedCountry,
                items: countries,
                onChanged: (val) {
                  setState(() {
                    _selectedCountry = val;
                    _selectedState = null;
                    _selectedCity = null;
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildFilterDropdown(
                hint: 'State',
                value: _selectedState,
                items: states,
                onChanged: (val) {
                  setState(() {
                    _selectedState = val;
                    _selectedCity = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterDropdown(
                hint: 'District',
                value: _selectedCity,
                items: cities,
                onChanged: (val) {
                  setState(() {
                    _selectedCity = val;
                  });
                },
              ),
              if (_selectedCountry != null || _selectedState != null || _selectedCity != null) ...[
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCountry = null;
                      _selectedState = null;
                      _selectedCity = null;
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ] else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: [
              ...items.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDiscoverState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No events found for this selection', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Try broadening your search or clearing filters.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
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

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final double borderRadius;
  final double width;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.borderRadius,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
          height: 1.25,
        );
    final valueStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF111827),
        );

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: valueStyle),
            const SizedBox(height: 6),
            Text(title, style: titleStyle),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String volunteerName;
  final String volunteerId;
  final double cardRadius;

  const _GreetingHeader({
    required this.volunteerName,
    required this.volunteerId,
    required this.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF4B5563),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.teal.withValues(alpha: 0.12),
            child: Text(
              volunteerName.isNotEmpty ? volunteerName.substring(0, 1) : 'V',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $volunteerName 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thanks for showing up. Your time creates real change.',
                  style: subtitleStyle,
                ),
                const SizedBox(height: 6),
                Text(
                  'Volunteer ID: ${_formatVolunteerId(volunteerId)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications (demo)'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.teal.shade700,
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }

  static String _formatVolunteerId(String id) {
    if (id.isEmpty) return '—';
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}…${id.substring(id.length - 4)}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double screenWidth;
  final double cardRadius;
  final List<_SummaryItem> items;

  const _SummaryRow({
    required this.screenWidth,
    required this.cardRadius,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalGaps = 12.0;
    final available =
        screenWidth - (20.0 * 2);

    // If the screen is wide enough, show three cards in a row. Otherwise,
    // fall back to a horizontally scrollable row to avoid overflow.
    final canFitRow = available >= 3 * 190 + 2 * horizontalGaps;

    if (canFitRow) {
      final cardWidth = (available - 2 * horizontalGaps) / 3;
      return Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            DashboardCard(
              title: items[i].title,
              value: items[i].value,
              icon: items[i].icon,
              accentColor: Colors.teal,
              borderRadius: cardRadius,
              width: cardWidth,
            ),
            if (i != items.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    }

    final cardWidth = (available * 0.72).clamp(220.0, 280.0);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            DashboardCard(
              title: items[i].title,
              value: items[i].value,
              icon: items[i].icon,
              accentColor: Colors.teal,
              borderRadius: cardRadius,
              width: cardWidth,
            ),
            if (i != items.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final _UpcomingEvent event;
  final double cardRadius;

  const _EventCard({
    required this.event,
    required this.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TagChip(
                      label: event.tag,
                      color: event.tagColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.dateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4B5563),
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4B5563),
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal.withValues(alpha: 0.10),
                      foregroundColor: Colors.teal.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing "${event.title}" (demo)'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                    child: const Text('View details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _RecentActivity activity;
  final double cardRadius;

  const _ActivityTile({
    required this.activity,
    required this.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: activity.iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: activity.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opened activity (demo): ${activity.title}'),
                  duration: const Duration(milliseconds: 900),
                ),
              );
            },
            icon: const Icon(Icons.chevron_right_rounded),
            color: const Color(0xFF9CA3AF),
            tooltip: 'Open',
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SummaryItem {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _UpcomingEvent {
  final String title;
  final String dateLabel;
  final String location;
  final String tag;
  final Color tagColor;

  const _UpcomingEvent({
    required this.title,
    required this.dateLabel,
    required this.location,
    required this.tag,
    required this.tagColor,
  });
}

class _RecentActivity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _RecentActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}
