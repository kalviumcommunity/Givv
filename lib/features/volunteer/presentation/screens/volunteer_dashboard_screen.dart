import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:givv/features/auth/providers/auth_providers.dart';

class VolunteerDashboardScreen extends ConsumerWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF6794AA);
    const textColor = Color(0xFF1F2937);

    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'GIVV',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, color: textColor),
                    onPressed: () async {
                      final repo = ref.read(authRepositoryProvider);
                      await repo.signOut();
                      if (context.mounted) context.go('/select-role');
                    },
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: userAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (user) => SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'Volunteer',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '• Volunteer',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Your Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stat cards
                      Row(
                        children: [
                          _buildStatCard(
                              'Hours Given', '0', Icons.access_time_outlined),
                          const SizedBox(width: 16),
                          _buildStatCard('Events', '0',
                              Icons.event_available_outlined),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Quick info
                      _buildInfoTile(
                          Icons.email_outlined, 'Email', user?.email ?? '—'),
                      _buildInfoTile(
                          Icons.phone_outlined, 'Phone', user?.phone ?? '—'),
                      _buildInfoTile(
                          Icons.location_on_outlined,
                          'Location',
                          '${user?.city ?? '—'}, ${user?.country ?? ''}'),
                      if (user?.organizationCode != null)
                        _buildInfoTile(Icons.group_outlined, 'Organization Code',
                            user!.organizationCode!),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatCard(String label, String value, IconData icon) {
    const primaryColor = Color(0xFF6794AA);
    const textColor = Color(0xFF1F2937);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: primaryColor, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoTile(IconData icon, String label, String value) {
    const textColor = Color(0xFF1F2937);
    const primaryColor = Color(0xFF6794AA);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
