import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  // CRITICAL: Initialize Flutter bindings first
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Initialize Firebase BEFORE running app
  // This ensures Firebase is ready for all subsequent auth calls
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Verify Firebase is initialized
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase initialization failed: No apps initialized');
    }
    
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    rethrow;
  }

  // Run app only after Firebase is fully initialized
  runApp(
    const ProviderScope(
      child: GivvApp(),
    ),
  );
}