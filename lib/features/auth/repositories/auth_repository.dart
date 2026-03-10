import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Comprehensive error message mapping for Firebase exceptions
/// Maps technical Firebase error codes to user-friendly messages
/// 
/// Handles:
/// - Auth errors (email in use, weak password, etc.)
/// - Firestore errors (profile not found, write failed, etc.)
/// - Network errors (connection, timeout, 400s, etc.)
/// - Web-specific errors (CORS, configuration, etc.)
String mapFirebaseError(dynamic exception) {
  // Handle FirebaseAuthException specifically
  if (exception is FirebaseAuthException) {
    switch (exception.code) {
      // ─── Registration Errors ─────────────────────────────────
      case 'email-already-in-use':
        return 'This email is already registered. Please log in instead.';

      case 'weak-password':
        return 'Password too weak. Use at least 6 characters.';

      case 'invalid-email':
        return 'Email address is not in valid format.';

      case 'operation-not-allowed':
        return 'Email/password signup is not enabled. Contact support.';

      // ─── Login Errors ────────────────────────────────────────
      case 'user-not-found':
        return 'No account found with this email. Please register first.';

      case 'wrong-password':
        return 'Incorrect password. Please try again.';

      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';

      case 'user-disabled':
        return 'This account has been disabled. Contact support.';

      // ─── Profile Errors ──────────────────────────────────────
      case 'no-current-user':
        return 'No user is currently logged in.';

      case 'user-profile-not-found':
        return 'User profile not found. Please log in again.';

      case 'firestore-error':
        return 'Failed to save user profile. Please try again.';

      // ─── Network Errors ──────────────────────────────────────
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      case 'too-many-requests':
        return 'Too many login attempts. Please wait a few minutes.';

      case 'timeout':
        return 'Request timed out. Please check your connection.';

      // ─── Web-Specific Errors ─────────────────────────────────
      case 'auth/network-request-failed':
        return 'Network connection failed. Please try again.';

      case 'cors-error':
        return 'CORS error. Please refresh and try again.';

      // ─── Unknown Error ───────────────────────────────────────
      case 'unknown-error':
        return 'An unexpected error occurred. Please try again.';

      default:
        return exception.message ?? 'An error occurred. Please try again.';
    }
  }

  // Handle generic exceptions
  final errorMsg = exception.toString().toLowerCase();

  if (errorMsg.contains('400')) {
    return 'Invalid request. Please check your input and try again.';
  }
  if (errorMsg.contains('401') || errorMsg.contains('unauthorized')) {
    return 'Authentication failed. Please try again.';
  }
  if (errorMsg.contains('403') || errorMsg.contains('permission')) {
    return 'Permission denied. Contact support if this persists.';
  }
  if (errorMsg.contains('404') || errorMsg.contains('not found')) {
    return 'Resource not found. Please try again.';
  }
  if (errorMsg.contains('500') || errorMsg.contains('server error')) {
    return 'Server error. Please try again later.';
  }
  if (errorMsg.contains('network') || errorMsg.contains('connection')) {
    return 'Network error. Check your internet connection.';
  }
  if (errorMsg.contains('firestore')) {
    return 'Database error. Please try again.';
  }
  if (errorMsg.contains('cors')) {
    return 'Web security error. Please refresh and try again.';
  }
  if (errorMsg.contains('timeout')) {
    return 'Request timed out. Please try again.';
  }

  return 'An unexpected error occurred. Please try again.';
}

/// Type-safe result wrapper for auth operations
/// Provides success/failure handling without throwing exceptions
class AuthResult<T> {
  final T? data;
  final String? errorMessage;

  const AuthResult.success(this.data) : errorMessage = null;
  const AuthResult.failure(this.errorMessage) : data = null;

  bool get isSuccess => errorMessage == null;
  bool get isFailure => errorMessage != null;
}

/// AuthRepository - Production-ready authentication business logic
/// 
/// Responsibilities:
/// 1. Call AuthService methods
/// 2. Map exceptions to user-friendly error messages
/// 3. Handle state (sign out after registration)
/// 4. Wrap results in AuthResult for type safety
class AuthRepository {
  final AuthService _authService = AuthService();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Registers an organization with error handling
  /// 
  /// Returns:
  /// - AuthResult.success(user) if successful
  /// - AuthResult.failure(message) if failed
  /// 
  /// Never throws - all errors converted to result
  Future<AuthResult<GivvUser>> registerOrganization({
    required String orgName,
    required String registrationNumber,
    required String email,
    required String phone,
    required String country,
    required String city,
    required String password,
  }) async {
    try {
      final user = await _authService.registerOrganization(
        orgName: orgName,
        registrationNumber: registrationNumber,
        email: email,
        phone: phone,
        country: country,
        city: city,
        password: password,
      );

      // Sign out after successful registration
      // User must explicitly log in for security
      await _authService.signOut();

      return AuthResult.success(user);
    } catch (e) {
      // Map exception to user-friendly message
      final errorMessage = mapFirebaseError(e);
      return AuthResult.failure(errorMessage);
    }
  }

  /// Registers a volunteer with error handling
  /// 
  /// Returns:
  /// - AuthResult.success(user) if successful
  /// - AuthResult.failure(message) if failed
  /// 
  /// Never throws - all errors converted to result
  Future<AuthResult<GivvUser>> registerVolunteer({
    required String name,
    required String email,
    required String phone,
    required String country,
    required String city,
    required String password,
    String? organizationCode,
  }) async {
    try {
      final user = await _authService.registerVolunteer(
        name: name,
        email: email,
        phone: phone,
        country: country,
        city: city,
        password: password,
        organizationCode: organizationCode,
      );

      // Sign out after successful registration
      // User must explicitly log in for security
      await _authService.signOut();

      return AuthResult.success(user);
    } catch (e) {
      // Map exception to user-friendly message
      final errorMessage = mapFirebaseError(e);
      return AuthResult.failure(errorMessage);
    }
  }

  /// Signs in a user with error handling
  /// 
  /// Returns:
  /// - AuthResult.success(user) if successful
  /// - AuthResult.failure(message) if failed
  /// 
  /// Never throws - all errors converted to result
  Future<AuthResult<GivvUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      return AuthResult.success(user);
    } catch (e) {
      // Map exception to user-friendly message
      final errorMessage = mapFirebaseError(e);
      return AuthResult.failure(errorMessage);
    }
  }

  /// Signs out the current user
  /// 
  /// Throws [Exception] if sign out fails
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Fetches the current user's profile
  /// 
  /// Returns null if not authenticated or profile not found
  Future<GivvUser?> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  /// Gets the current user's role
  /// 
  /// Returns null if not authenticated or role not found
  Future<UserRole?> getCurrentUserRole() async {
    return _authService.getCurrentUserRole();
  }
}
