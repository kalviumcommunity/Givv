// Opportunity Card Widget
import 'package:flutter/material.dart';

class OpportunityCard extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityCard({
    required this.opportunity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = opportunity['title'] ?? 'Untitled';
    final organization = opportunity['organizationName'] ?? 'Unknown Organization';
    final hours = opportunity['estimatedHours'] ?? 'TBD';
    final location = opportunity['location'] ?? 'Remote';
    final description = opportunity['description'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6794AA).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      organization,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6794AA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6794AA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (description.isNotEmpty) const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$hours hours',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6794AA),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
