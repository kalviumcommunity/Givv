import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../models/user_model.dart';

/// Diagnostic utilities for debugging Firebase issues
class _FirebaseDebug {
  static Future<void> logInitialization() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('🔍 Firebase Debug Info:');
      debugPrint('   - Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      debugPrint('   - Current User: ${currentUser?.email}');
    } catch (e) {
      debugPrint('❌ Debug logging failed: $e');
    }
  }

  static void logException(
      String operation, FirebaseAuthException e, String email) {
    debugPrint('❌ Firebase $operation failed:');
    debugPrint('   - Code: ${e.code}');
    debugPrint('   - Message: ${e.message}');
    debugPrint('   - Email: $email');
    debugPrint('   - Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
  }
}

/// Production-ready AuthService with Firebase Auth operations
/// Handles Web + Mobile, proper error handling, and rollback on failure
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current authenticated user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Validates email format before Firebase call
  /// Prevents 400 errors from invalid email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength
  /// Prevents 400 errors from weak password
  static bool _isValidPassword(String password) {
    // Firebase minimum: 6 characters
    return password.isNotEmpty && password.length >= 6;
  }

  /// Registers an organization admin with proper error handling
  /// 
  /// Process:
  /// 1. Validate email format locally
  /// 2. Validate password strength locally
  /// 3. Create Firebase Auth user
  /// 4. Create Firestore user profile
  /// 5. Rollback if Firestore fails
  /// 
  /// Throws [FirebaseAuthException] for auth errors
  /// Throws generic [Exception] for other errors
  Future<GivvUser> registerOrganization({
    required String orgName,
    required String registrationNumber,
    required String email,
    required String phone,
    required String country,
    required String city,
    required String password,
  }) async {
    // Validate inputs BEFORE Firebase call (prevents 400 errors)
    if (!_isValidEmail(email.trim())) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Email address is not in valid format',
      );
    }

    if (!_isValidPassword(password)) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password must be at least 6 characters',
      );
    }

    try {
      debugPrint('📝 Registering organization: $email');
      await _FirebaseDebug.logInitialization();

      // Step 1: Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      debugPrint('✅ Auth user created: $uid');

      // Step 2: Build user object
      final user = GivvUser(
        uid: uid,
        name: orgName,
        email: email.trim(),
        role: UserRole.organizer,
        organizationName: orgName,
        registrationNumber: registrationNumber,
        phone: phone,
        country: country,
        city: city,
        createdAt: DateTime.now(),
      );

      // Step 3: Write to Firestore
      try {
        debugPrint('💾 Writing user profile to Firestore...');
        debugPrint('   ├─ UID: $uid');
        debugPrint('   ├─ Email: ${user.email}');
        debugPrint('   ├─ Name: ${user.name}');
        debugPrint('   └─ Role: ${user.role}');
        
        await _firestore
            .collection('users')
            .doc(uid)
            .set(user.toFirestore());
        
        debugPrint('✅ User profile created in Firestore');
        return user;
      } catch (firestoreError) {
        // CRITICAL: Log the exact error for debugging
        debugPrint('❌ Firestore write FAILED:');
        debugPrint('   Error: ${firestoreError.toString()}');
        debugPrint('   Type: ${firestoreError.runtimeType}');
        
        // Rollback - Delete Firebase Auth user if Firestore fails
        debugPrint('⚠️ Rolling back Auth user creation...');
        try {
          await credential.user?.delete();
          debugPrint('✅ Rollback successful: Auth user deleted');
        } catch (rollbackError) {
          debugPrint('❌ Rollback FAILED (user may be orphaned): $rollbackError');
        }
        throw Exception('firestore-error: ${firestoreError.toString()}');
      }
    } on FirebaseAuthException catch (e) {
      _FirebaseDebug.logException('registerOrganization', e, email);
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('unknown-error: Registration failed. Please try again.');
    }
  }

  /// Registers a volunteer with proper error handling
  /// 
  /// Same process as organization registration
  Future<GivvUser> registerVolunteer({
    required String name,
    required String email,
    required String phone,
    required String country,
    required String city,
    required String password,
    String? organizationCode,
  }) async {
    // Validate inputs BEFORE Firebase call (prevents 400 errors)
    if (!_isValidEmail(email.trim())) {
      throw Exception('invalid-email: Email address is not in valid format');
    }

    if (!_isValidPassword(password)) {
      throw Exception('weak-password: Password must be at least 6 characters');
    }

    try {
      debugPrint('📝 Registering volunteer: $email');
      await _FirebaseDebug.logInitialization();

      // Step 1: Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      debugPrint('✅ Auth user created: $uid');

      // Step 2: Build user object
      final user = GivvUser(
        uid: uid,
        name: name,
        email: email.trim(),
        role: UserRole.volunteer,
        phone: phone,
        country: country,
        city: city,
        organizationCode: organizationCode?.trim().isNotEmpty == true
            ? organizationCode!.trim()
            : null,
        createdAt: DateTime.now(),
      );

      // Step 3: Write to Firestore
      try {
        debugPrint('💾 Writing user profile to Firestore...');
        debugPrint('   ├─ UID: $uid');
        debugPrint('   ├─ Email: ${user.email}');
        debugPrint('   ├─ Name: ${user.name}');
        debugPrint('   └─ Role: ${user.role}');
        
        await _firestore
            .collection('users')
            .doc(uid)
            .set(user.toFirestore());
        
        debugPrint('✅ User profile created in Firestore');
        return user;
      } catch (firestoreError) {
        // CRITICAL: Log the exact error for debugging
        debugPrint('❌ Firestore write FAILED:');
        debugPrint('   Error: ${firestoreError.toString()}');
        debugPrint('   Type: ${firestoreError.runtimeType}');
        
        // Rollback - Delete Firebase Auth user if Firestore fails
        debugPrint('⚠️ Rolling back Auth user creation...');
        try {
          await credential.user?.delete();
          debugPrint('✅ Rollback successful: Auth user deleted');
        } catch (rollbackError) {
          debugPrint('❌ Rollback FAILED (user may be orphaned): $rollbackError');
        }
        throw Exception('firestore-error: ${firestoreError.toString()}');
      }
    } on FirebaseAuthException catch (e) {
      _FirebaseDebug.logException('registerVolunteer', e, email);
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('unknown-error: Registration failed. Please try again.');
    }
  }

  /// Signs in a user with email and password
  /// 
  /// Process:
  /// 1. Validate email format locally
  /// 2. Sign in with Firebase Auth
  /// 3. Verify Firestore profile exists
  /// 
  /// Returns GivvUser or throws exception
  Future<GivvUser> signIn({
    required String email,
    required String password,
  }) async {
    // Validate inputs BEFORE Firebase call
    if (!_isValidEmail(email.trim())) {
      throw Exception('invalid-email: Email address is not in valid format');
    }

    try {
      debugPrint('🔑 Signing in: $email');
      await _FirebaseDebug.logInitialization();

      // Step 1: Authenticate user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('✅ Auth successful: ${userCredential.user?.email}');

      // Step 2: Fetch user profile from Firestore
      return await getCurrentUser();
    } on FirebaseAuthException catch (e) {
      _FirebaseDebug.logException('signIn', e, email);
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected sign-in error: $e');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'Sign in failed. Please try again.',
      );
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      debugPrint('👋 Signing out...');
      await _auth.signOut();
      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Fetches the current user's profile from Firestore
  /// 
  /// Throws if user not authenticated or profile not found in Firestore
  Future<GivvUser> getCurrentUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('no-current-user: No authenticated user');
      }

      debugPrint('📖 Fetching user profile: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw Exception('user-profile-not-found: User profile not found in database');
      }

      debugPrint('✅ User profile found');
      return GivvUser.fromFirestore(doc);
    } catch (e) {
      debugPrint('❌ Get current user failed: $e');
      rethrow;
    }
  }

  /// Gets the current user's role (returns null if not found)
  Future<UserRole?> getCurrentUserRole() async {
    try {
      final user = await getCurrentUser();
      return user.role;
    } catch (e) {
      debugPrint('⚠️ Get role failed: $e');
      return null;
    }
  }
}
