import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  final Event event;

  const EventInfoCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: const TextStyle(color: Color(0xFF00796B), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  event.status.name.toUpperCase(),
                  style: TextStyle(
                    color: event.status == EventStatus.ongoing ? Colors.green : Colors.blueGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_month_outlined, DateFormat('MMM dd, yyyy - hh:mm a').format(event.date)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, event.city),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.people_outline, '${event.volunteersJoined.length} / ${event.maxVolunteers} Volunteers'),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(color: Colors.blueGrey[600], height: 1.5),
            ),
            if (event.tasksDescription != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Tasks Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                event.tasksDescription!,
                style: TextStyle(color: Colors.blueGrey[600], height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6794AA)),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.black87, fontSize: 14)),
      ],
    );
  }
}
