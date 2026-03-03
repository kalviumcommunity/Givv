import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Give Firebase a moment to emit auth state
    Future.delayed(const Duration(milliseconds: 2000), _checkAuthAndNavigate);
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted || _navigated) return;

    final authAsync = ref.read(authStateProvider);

    authAsync.when(
      data: (firebaseUser) async {
        if (!mounted || _navigated) return;
        _navigated = true;

        if (firebaseUser == null) {
          // Not logged in → role selection
          context.go('/select-role');
        } else {
          // Logged in → fetch role and redirect
          final repo = ref.read(authRepositoryProvider);
          final role = await repo.getCurrentUserRole();
          if (!mounted) return;

          if (role == 'organizationAdmin') {
            context.go('/org-dashboard');
          } else if (role == 'volunteer') {
            context.go('/volunteer-dashboard');
          } else {
            // Unknown role → fallback to select-role
            context.go('/select-role');
          }
        }
      },
      loading: () {
        // Auth state still loading — listen again after short delay
        Future.delayed(
          const Duration(milliseconds: 500),
          _checkAuthAndNavigate,
        );
      },
      error: (_, __) {
        if (!mounted || _navigated) return;
        _navigated = true;
        context.go('/select-role');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6794AA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background soft glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 60,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'GIVV',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coordinating Volunteers.\nDelivering Impact.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  'INITIALIZING •',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Animated loading indicator
                const SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFF3F4F6),
                    color: primaryColor,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'VERSION 2.4.0',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1.0,
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
