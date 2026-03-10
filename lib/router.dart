import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/role_selection_screen.dart';
import 'features/auth/presentation/organization_signup_screen.dart';
import 'features/auth/presentation/volunteer_signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/profile_screen.dart';
import 'features/organization/presentation/screens/organization_dashboard_screen.dart';
import 'features/organization/presentation/screens/create_event_screen.dart';
import 'features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import 'features/organization/presentation/screens/event_details_screen.dart';
import 'features/volunteer/presentation/screens/leaderboard_screen.dart';
import 'features/volunteer/presentation/screens/my_events_screen.dart';
import 'features/volunteer/presentation/screens/my_tasks_screen.dart';
import 'features/volunteer/presentation/screens/volunteer_event_details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state so router refreshes when auth changes
  final authStateListenable = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authStateListenable,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final isLoggedIn = authAsync.valueOrNull != null;

      final protectedRoutes = ['/org-dashboard', '/volunteer-dashboard', '/leaderboard'];
      final isGoingToProtected =
          protectedRoutes.any((r) => state.matchedLocation.startsWith(r));

      // If not logged in and trying to access protected route → login
      if (!isLoggedIn && isGoingToProtected) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/select-role',
        name: 'select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/org-signup',
        name: 'org-signup',
        builder: (context, state) => const OrganizationSignupScreen(),
      ),
      GoRoute(
        path: '/volunteer-signup',
        name: 'volunteer-signup',
        builder: (context, state) => const VolunteerSignupScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/org-dashboard',
        name: 'org-dashboard',
        builder: (context, state) => const OrganizationDashboardScreen(),
        routes: [
          GoRoute(
            path: 'create-event',
            name: 'create-event',
            builder: (context, state) => const CreateEventScreen(),
          ),
          GoRoute(
            path: 'event-details/:id',
            name: 'org-event-details',
            builder: (context, state) => EventDetailsScreen(eventId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/volunteer-dashboard',
        name: 'volunteer-dashboard',
        builder: (context, state) => const VolunteerDashboardScreen(),
        routes: [
          GoRoute(
            path: 'my-events',
            name: 'my-events',
            builder: (context, state) => const MyEventsScreen(),
          ),
          GoRoute(
            path: 'my-tasks',
            name: 'my-tasks',
            builder: (context, state) => const MyTasksScreen(),
          ),
          GoRoute(
            path: 'event-details/:id',
            name: 'volunteer-event-details',
            builder: (context, state) => VolunteerEventDetailsScreen(eventId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

/// Notifier that triggers GoRouter to re-evaluate redirects on auth changes.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
