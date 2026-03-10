import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    final content = userAsync.when(
      data: (user) {
        if (user == null) return const Center(child: Text('User found'));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              if (user.role == UserRole.volunteer) _buildVolunteerStats(user),
              const SizedBox(height: 24),
              _buildInfoSection(user),
              const SizedBox(height: 32),
              _buildSettingsSection(context, ref),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );

    if (isTab) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              // Edit profile logic
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildProfileHeader(GivvUser user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFFE2E8F0),
          child: user.profileImageUrl != null
              ? ClipOval(child: Image.network(user.profileImageUrl!, fit: BoxFit.cover, width: 100, height: 100))
              : const Icon(Icons.person, size: 50, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user.role == UserRole.organizer ? user.organizationName ?? 'Organization' : 'Dedicated Volunteer',
          style: const TextStyle(color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildVolunteerStats(GivvUser user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6794AA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Points', '${user.points}', Colors.white),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildStatItem('Events', '${user.eventsJoined}', Colors.white),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildStatItem('Tasks', '${user.tasksCompleted}', Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoSection(GivvUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, 'Phone', user.phone),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on_outlined, 'Location', '${user.city}, ${user.country}'),
          if (user.role == UserRole.organizer && user.organizationCode != null) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.vpn_key_outlined, 'Org Code', user.organizationCode!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6794AA)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSettingsTile(Icons.notifications_none, 'Notifications', () {}),
        _buildSettingsTile(Icons.security, 'Privacy & Security', () {}),
        _buildSettingsTile(Icons.help_outline, 'Help & Support', () {}),
        const SizedBox(height: 16),
        _buildSettingsTile(Icons.logout, 'Sign Out', () async {
          await ref.read(authRepositoryProvider).signOut();
          if (context.mounted) context.go('/select-role');
        }, color: Colors.red),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String label, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
