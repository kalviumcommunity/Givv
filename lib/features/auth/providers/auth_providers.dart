import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// ─── Auth Repository Provider ─────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ─── Auth State Stream (Firebase auth changes) ────────────────────────────────
// Emits the raw Firebase User? on login/logout
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// ─── Selected Role (temporary, during sign-up flow) ──────────────────────────
// 'org' or 'volunteer'
final selectedRoleProvider = StateProvider<String?>((ref) => null);

// ─── Current GIVV User from Firestore ────────────────────────────────────────
// Re-fetches whenever auth state changes (user logs in/out)
final currentUserProvider = FutureProvider<GivvUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (firebaseUser) async {
      if (firebaseUser == null) return null;
      final repo = ref.read(authRepositoryProvider);
      return repo.getCurrentUser();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ─── User Role ────────────────────────────────────────────────────────────────
// Derives role string from currentUserProvider
final userRoleProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenOrNull(data: (user) => user?.role);
});
