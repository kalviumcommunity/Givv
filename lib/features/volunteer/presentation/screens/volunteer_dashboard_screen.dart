import 'package:flutter/material.dart';

class VolunteerDashboardScreen extends StatelessWidget {
  final String volunteerId;

  const VolunteerDashboardScreen({
    super.key,
    required this.volunteerId,
  });

  static const _pagePadding = 16.0;
  static const _cardRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Dummy static data (replace with real state later).
    const volunteerName = 'Akshad';
    const summary = [
      _SummaryItem(
        title: 'Total Hours\nContributed',
        value: '128',
        icon: Icons.timelapse_rounded,
      ),
      _SummaryItem(
        title: 'Active\nEvents',
        value: '4',
        icon: Icons.event_available_rounded,
      ),
      _SummaryItem(
        title: 'Impact\nScore',
        value: '92',
        icon: Icons.emoji_events_rounded,
      ),
    ];

    final upcomingEvents = <_UpcomingEvent>[
      _UpcomingEvent(
        title: 'Community Food Drive',
        dateLabel: 'Sat, Mar 2 • 10:00 AM',
        location: 'Andheri, Mumbai',
        tag: 'On-site',
        tagColor: Colors.teal,
      ),
      _UpcomingEvent(
        title: 'Beach Cleanup',
        dateLabel: 'Sun, Mar 10 • 7:30 AM',
        location: 'Juhu Beach',
        tag: 'Outdoor',
        tagColor: Colors.blue,
      ),
      _UpcomingEvent(
        title: 'Mentorship Call',
        dateLabel: 'Wed, Mar 13 • 6:00 PM',
        location: 'Online',
        tag: 'Virtual',
        tagColor: Colors.indigo,
      ),
    ];

    final recentActivity = <_RecentActivity>[
      _RecentActivity(
        title: 'Completed: Donation Sorting',
        subtitle: '2 hours • Yesterday',
        icon: Icons.check_circle_rounded,
        iconColor: Colors.teal,
      ),
      _RecentActivity(
        title: 'Joined: Food Drive Team',
        subtitle: 'New event • 3 days ago',
        icon: Icons.group_add_rounded,
        iconColor: Colors.blue,
      ),
      _RecentActivity(
        title: 'Earned: Impact Badge',
        subtitle: 'Milestone • 1 week ago',
        icon: Icons.verified_rounded,
        iconColor: Colors.indigo,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Volunteer Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        indicatorColor: Colors.teal.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          final label = switch (index) {
            0 => 'Home',
            1 => 'Events',
            2 => 'Messages',
            _ => 'Profile',
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label tapped (demo)'),
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingHeader(
                volunteerName: volunteerName,
                volunteerId: volunteerId,
                cardRadius: _cardRadius,
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: 'Summary',
                trailing: Text(
                  'This month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                screenWidth: size.width,
                cardRadius: _cardRadius,
                items: summary,
              ),
              const SizedBox(height: 20),
              const _SectionHeader(title: 'Upcoming Events'),
              const SizedBox(height: 12),
              Column(
                children: [
                  for (final event in upcomingEvents) ...[
                    _EventCard(event: event, cardRadius: _cardRadius),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              const _SectionHeader(title: 'Recent Activity'),
              const SizedBox(height: 12),
              Column(
                children: [
                  for (final activity in recentActivity) ...[
                    _ActivityTile(activity: activity, cardRadius: _cardRadius),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
              const SizedBox(height: 24),
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
    final available = screenWidth - (VolunteerDashboardScreen._pagePadding * 2);

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