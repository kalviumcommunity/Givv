import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/role_selection_screen.dart';
import 'features/auth/presentation/organization_signup_screen.dart';
import 'features/auth/presentation/volunteer_signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';

class GivvApp extends ConsumerWidget {
  const GivvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'GIVV',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6794AA),
          primary: const Color(0xFF6794AA),
        ),
      ),
      routerConfig: router,
      // Set SplashScreen as the home screen
      home: const SplashScreen(),
      // Define named routes for the flow
      routes: {
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/signup-org': (context) => const OrganizationSignupScreen(),
        '/signup-volunteer': (context) => const VolunteerSignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/volunteer-dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final volunteerId = args is String ? args : 'default_volunteer_id';
          return VolunteerDashboardScreen(volunteerId: volunteerId);
        },
        // … other routes …
      },
    );
  }
}