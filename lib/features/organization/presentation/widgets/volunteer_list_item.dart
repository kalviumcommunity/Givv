import 'package:flutter/material.dart';

class VolunteerListItem extends StatelessWidget {
  final int rank;
  final String name;
  final String projects;
  final String points;
  final String imageUrl;

  const VolunteerListItem({
    super.key,
    required this.rank,
    required this.name,
    required this.projects,
    required this.points,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getRankColor(rank),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  projects,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
              ),
              Text(
                'POINTS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      letterSpacing: 0.5,
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blueAccent;
      case 3:
        return Colors.deepOrangeAccent;
      default:
        return Colors.grey;
    }
  }
}
