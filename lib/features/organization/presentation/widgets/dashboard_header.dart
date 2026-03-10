import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String organizationName;
  final String role;
  final VoidCallback? onSignOut;

  const DashboardHeader({
    super.key,
    required this.organizationName,
    required this.role,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.volunteer_activism,
            color: Color(0xFF1976D2),
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organizationName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                role,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
        ),
        if (onSignOut != null)
          IconButton(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_outlined, color: Colors.redAccent),
            tooltip: 'Sign out',
          ),
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFE3F2FD),
          child: ClipOval(
            child: Image.network(
              'https://ui-avatars.com/api/?name=${organizationName.replaceAll(' ', '+')}&background=6794AA&color=fff',
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 20, color: Color(0xFF1976D2)),
            ),
          ),
        ),
      ],
    );
  }
}
