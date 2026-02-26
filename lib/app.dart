import 'package:flutter/material.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/role_selection_screen.dart';
import 'features/auth/presentation/organization_signup_screen.dart';
import 'features/auth/presentation/volunteer_signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';

class GivvApp extends StatelessWidget {
  const GivvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // Set SplashScreen as the home screen
      home: const SplashScreen(),
      // Define named routes for the flow
      routes: {
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/signup-org': (context) => const OrganizationSignupScreen(),
        '/signup-volunteer': (context) => const VolunteerSignupScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}