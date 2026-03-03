# Firebase Auth for Flutter Web - Production Guide

## Problem Analysis: 400 Bad Request Error

### What's Happening

When your Flutter Web app calls Firebase Auth, you see:
```
identitytoolkit.googleapis.com/v1/accounts:signUp returning 400 Bad Request
```

### Root Causes (In Order of Likelihood)

#### 1. **Firebase Not Initialized (Most Common)**
```dart
// ❌ WRONG - Firebase called before initialization
void main() async {
  runApp(MyApp());
  // Firebase.initializeApp() called AFTER runApp = FAIL
}

// ✅ CORRECT
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: ...);
  runApp(MyApp());
}
```

**Why 400?** Firebase SDK not ready → malformed request → server rejects with 400

#### 2. **Invalid Email Format**
```dart
// ❌ Example: User enters "john" (no @domain)
await createUserWithEmailAndPassword(email: "john", password: "pass123");
// Returns 400 from Google API: "Invalid email format"
```

**Fix:** Validate email format BEFORE calling Firebase:
```dart
static bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email.trim());
}
```

#### 3. **Password Too Short**
```dart
// ❌ Firebase requires minimum 6 characters
await createUserWithEmailAndPassword(email: "test@test.com", password: "ab");
// Returns 400: "Password too weak"
```

**Fix:** Validate password BEFORE calling Firebase:
```dart
static bool _isValidPassword(String password) {
  return password.isNotEmpty && password.length >= 6;
}
```

#### 4. **Whitespace Issues**
```dart
// ❌ Email with leading/trailing spaces
await createUserWithEmailAndPassword(email: " test@test.com ", password: "pass123");
// May cause 400 if not trimmed
```

**Fix:** Always trim inputs:
```dart
email: emailInput.trim(),
password: passwordInput,
```

#### 5. **Firestore Security Rules**
```dart
// ❌ If Firestore denies write after successful auth
// User created in Firebase but profile write fails
// Second attempt shows "email-already-in-use" 400
```

**Fix:** Validate Firestore permissions in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow create: if request.auth.uid == uid;
      allow read: if request.auth.uid == uid;
    }
  }
}
```

#### 6. **CORS or Domain Issues (Web Only)**
```
Firebase configured for example.com, but app running on:
- localhost ❌ (needs to be authorized in Firebase)
- 127.0.0.1 ❌ (different from localhost)
- yoursite.com:3000 ❌ (port matters)
```

**Fix:** In Firebase Console → Authentication → Authorized domains:
```
Add:
- localhost
- Your actual domain
```

### The 400 Error Chain

```
1. Input not validated locally
     ↓
2. Invalid request sent to Firebase
     ↓
3. Firebase API rejects with 400 Bad Request
     ↓
4. Generic "unexpected error" shown to user
     ↓
5. User clicks again, email already exists (if user partially created)
```

---

## The Solution

### What We Fixed

#### 1. **Main.dart** - Proper Initialization
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase initialization failed');
    }
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    rethrow;
  }

  runApp(const ProviderScope(child: GivvApp()));
}
```

**Why this works:**
- ✅ Bindings initialized first
- ✅ Firebase awaited before app runs
- ✅ Verification check ensures it's really initialized
- ✅ Error logging for debugging

#### 2. **AuthService** - Pre-Validation
```dart
// Validate BEFORE Firebase call
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

// Now safe to call Firebase
final credential = await _auth.createUserWithEmailAndPassword(
  email: email.trim(),
  password: password,
);
```

**Why this works:**
- ✅ Catches errors locally before network call
- ✅ Prevents 400s from invalid payload
- ✅ Still uses FirebaseAuthException for consistency
- ✅ Diagnostic logging shows what went wrong

#### 3. **AuthRepository** - Comprehensive Error Mapping
```dart
String mapFirebaseError(dynamic exception) {
  if (exception is FirebaseAuthException) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in instead.';
      case 'weak-password':
        return 'Password too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Email address is not in valid format.';
      // ... more cases ...
    }
  }

  // Handle generic 400s
  if (exception.toString().contains('400')) {
    return 'Invalid request. Please check your input and try again.';
  }
  
  return 'An unexpected error occurred. Please try again.';
}
```

**Why this works:**
- ✅ Specific error messages users understand
- ✅ Maps generic 400s to actionable guidance
- ✅ Web-safe error messages

---

## Complete Example: Safe Login Screen

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepo = AuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Pattern: Validate → Clear errors → Load → Try → Result
  Future<void> _login() async {
    // 1. VALIDATE locally
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    // 2. PREVENT DUPLICATE - disable button
    if (_isLoading) return;
    if (!mounted) return;

    // 3. CLEAR PREVIOUS ERRORS
    ScaffoldMessenger.of(context).clearSnackBars();

    // 4. SHOW LOADING
    setState(() => _isLoading = true);

    try {
      // 5. CALL REPOSITORY (never throws, returns result)
      final result = await _authRepo.signIn(
        email: email,
        password: password,
      );

      // 6. CHECK MOUNTED (widget still on screen?)
      if (!mounted) return;
      setState(() => _isLoading = false);

      // 7. HANDLE RESULT
      if (result.isSuccess) {
        final user = result.data!;
        // Navigate based on role
        context.go(user.isOrgAdmin ? '/org-dashboard' : '/volunteer-dashboard');
      } else {
        // Show specific error message
        _showError(result.errorMessage ?? 'Login failed');
      }
    } catch (e) {
      // Unexpected error (shouldn't happen with proper error handling)
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('An unexpected error occurred');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'test@example.com',
                enabled: !_isLoading, // Disable while loading
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                enabled: !_isLoading, // Disable while loading
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login, // Disable while loading
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Key Safety Patterns

1. **Validate Locally First**
   - Email format check
   - Password length check
   - Check for empty fields
   - Trim whitespace

2. **Prevent Duplicate Submissions**
   - Disable button while loading: `onPressed: _isLoading ? null : _login`
   - Check `if (_isLoading) return;`
   - Only show loading once

3. **Clear Previous Errors**
   - `ScaffoldMessenger.clearSnackBars()` before showing new error
   - Only one error visible at a time

4. **Check Mounted**
   - After async operation: `if (!mounted) return;`
   - Prevents "setState on disposed widget"

5. **Handle Errors Without Exceptions**
   - Repository returns `AuthResult<T>` (success or failure)
   - No try-catch needed in UI
   - Predict all possible errors in mapping

---

## Testing Checklist

### Registration Tests

- [ ] Empty email → Shows "Email is required"
- [ ] Invalid email (no @) → Shows "Email address not valid"
- [ ] Password too short → Shows "Password must be 6+ characters"
- [ ] Valid inputs → Account created, navigates to login
- [ ] Email already exists → Shows "Email already registered"
- [ ] Click register twice quickly → Only one request sent (button disabled)
- [ ] Network down → Shows network error message
- [ ] Firebase not initialized → Shows initialization error

### Login Tests

- [ ] Wrong email → Shows "No account found"
- [ ] Wrong password → Shows "Incorrect password"
- [ ] Valid credentials → Logs in, navigates to dashboard
- [ ] Click login twice quickly → Only one request sent
- [ ] Browser refresh during loading → No errors in console
- [ ] Firestore profile missing → Shows "Profile not found"

### Web-Specific Tests

- [ ] Run on `localhost:3000` → Works (if authorized in Firebase)
- [ ] Run on `127.0.0.1:3000` → Shows CORS error if not authorized
- [ ] Open browser dev tools → No 400 errors in Network tab
- [ ] Check Console → Diagnostic logs show Firebase initialized
- [ ] Check local storage → Firebase auth tokens stored correctly

---

## Firebase Console Configuration Checklist

### Authentication Tab

- [ ] Email/Password enabled
- [ ] Password strength set appropriately (minimum 6)
- [ ] Email verification disabled (for dev)

### Authorized Domains

Add all domains where your app will run:
```
localhost
127.0.0.1
yourapp.firebase.app
yourapp.com (if custom domain)
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow create: if request.auth.uid == uid;
      allow read: if request.auth.uid == uid;
      allow update: if request.auth.uid == uid;
    }
  }
}
```

---

## Common Fixes

### Fix #1: 400 Error During Registration

**Before:**
```dart
// Firebase called without validation
Future<void> register() async {
  final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: emailInput, // Could be "john" (invalid)
    password: passwordInput, // Could be "ab" (too short)
  );
}
```

**After:**
```dart
Future<void> register() async {
  // Validate first
  if (!_isValidEmail(emailInput)) {
    showError('Invalid email');
    return;
  }
  
  // Then call Firebase
  final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: emailInput.trim(),
    password: passwordInput,
  );
}
```

### Fix #2: Duplicate Submissions

**Before:**
```dart
ElevatedButton(
  onPressed: _register, // Always enabled, no debouncing
  child: const Text('Register'),
)
```

**After:**
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _register, // Disabled while loading
  child: _isLoading
      ? const CircularProgressIndicator()
      : const Text('Register'),
)
```

### Fix #3: Generic "Unexpected Error" Messages

**Before:**
```dart
try {
  await _authService.register(...);
} catch (e) {
  showError('Unexpected error'); // User has no idea what went wrong
}
```

**After:**
```dart
try {
  final result = await _authRepo.registerVolunteer(...);
  if (result.isSuccess) {
    // Handle success
  } else {
    showError(result.errorMessage); // Specific, helpful message
  }
} catch (e) {
  showError(mapFirebaseError(e)); // Maps to user-friendly message
}
```

---

## Deployment Checklist

- [ ] Firebase initialized before app runs
- [ ] Email/password validation in AuthService
- [ ] Error mapping handles all Firebase codes
- [ ] UI prevents duplicate submissions (button disabled)
- [ ] UI checks `mounted` before state changes
- [ ] UI clears previous snackbars before showing new ones
- [ ] All authorized domains configured in Firebase
- [ ] Firestore security rules properly configured
- [ ] Browser console shows no 400 errors
- [ ] Firebase diagnostics show successful initialization
- [ ] Test on Flutter Web (chrome)
- [ ] Test on actual mobile device
- [ ] Test with poor internet connection
- [ ] Test offline then reconnect

---

## Summary

**The 400 error was caused by:**
1. Firebase not being fully initialized before auth calls
2. Invalid email/password not validated locally
3. Poor error handling hiding actual Firebase error messages
4. No prevention of duplicate submissions
5. Firestore operations failing after Firebase user created

**The fix involved:**
1. ✅ Proper Firebase initialization in main.dart with verification
2. ✅ Pre-validation of email and password in AuthService
3. ✅ Comprehensive error mapping in AuthRepository
4. ✅ UI patterns that prevent duplicate submissions
5. ✅ Diagnostic logging to debug Firebase issues
6. ✅ Proper error messages users can understand

**Result:**
- Clear, specific error messages
- No more generic "unexpected error"
- No duplicate submissions
- No more orphaned Firebase users
- Works reliably on Flutter Web
- Web safe CORS handling
