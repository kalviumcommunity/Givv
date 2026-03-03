# Production-Ready Example: Safe Login & Register Screen

## Complete Example - Login Screen

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';

/// Production-ready login screen with all safety patterns
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Dependencies
  final _authRepo = AuthRepository();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// PATTERN: Validate → Clear Errors → Load → Try → Handle Result
  Future<void> _handleSignIn() async {
    // ━━━━━ 1. VALIDATE INPUTS LOCALLY ━━━━━
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Email is required');
      return; // EARLY RETURN - don't proceed
    }

    if (password.isEmpty) {
      _showError('Password is required');
      return; // EARLY RETURN - don't proceed
    }

    // ━━━━━ 2. PREVENT DUPLICATE SUBMISSIONS ━━━━━
    if (_isLoading) return; // Already loading - ignore tap
    if (!mounted) return; // Widget disposed - ignore tap

    // ━━━━━ 3. CLEAR PREVIOUS ERRORS ━━━━━
    ScaffoldMessenger.of(context).clearSnackBars();

    // ━━━━━ 4. SHOW LOADING STATE ━━━━━
    setState(() => _isLoading = true);

    try {
      // ━━━━━ 5. CALL REPOSITORY ━━━━━
      // Repository handles all exceptions and returns result
      final result = await _authRepo.signIn(
        email: email,
        password: password,
      );

      // ━━━━━ 6. CHECK IF WIDGET STILL MOUNTED ━━━━━
      // Important: async operation may complete after widget disposed
      if (!mounted) return;
      setState(() => _isLoading = false);

      // ━━━━━ 7. HANDLE RESULT ━━━━━
      if (result.isSuccess) {
        // Sign in successful
        final user = result.data!;

        // Navigate based on user role
        if (user.isOrgAdmin) {
          if (mounted) context.go('/org-dashboard');
        } else if (user.isVolunteer) {
          if (mounted) context.go('/volunteer-dashboard');
        } else {
          _showError('Unknown user role. Contact support.');
        }
      } else {
        // Sign in failed - show specific error message
        _showError(result.errorMessage ?? 'Sign in failed. Please try again.');
      }
    } catch (e) {
      // Unexpected error (shouldn't happen with proper error handling)
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Unexpected error: $e');
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  /// Shows error snackbar with previous ones cleared (prevents duplicates)
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.volunteer_activism, size: 40),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your details to sign in',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // ━━━━━ EMAIL FIELD ━━━━━
              TextField(
                controller: _emailController,
                enabled: !_isLoading, // Disabled while loading
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ━━━━━ PASSWORD FIELD ━━━━━
              TextField(
                controller: _passwordController,
                enabled: !_isLoading, // Disabled while loading
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      if (!_isLoading) {
                        setState(() => _obscurePassword = !_obscurePassword);
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ━━━━━ SIGN IN BUTTON ━━━━━
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ━━━━━ SIGN UP LINK ━━━━━
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? '),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.go('/register'),
                    child: const Text('Sign up'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Complete Example - Registration Screen

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';

/// Production-ready volunteer registration screen
class VolunteerSignupScreen extends StatefulWidget {
  const VolunteerSignupScreen({super.key});

  @override
  State<VolunteerSignupScreen> createState() => _VolunteerSignupScreenState();
}

class _VolunteerSignupScreenState extends State<VolunteerSignupScreen> {
  // Dependencies
  final _authRepo = AuthRepository();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email.trim());
  }

  /// PATTERN: Validate → Clear Errors → Load → Try → Handle Result
  Future<void> _handleRegister() async {
    // ━━━━━ 1. VALIDATE INPUTS LOCALLY ━━━━━
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final country = _countryController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text;

    // Check required fields
    if (name.isEmpty) {
      _showError('Full name is required');
      return;
    }
    if (email.isEmpty) {
      _showError('Email is required');
      return;
    }
    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }
    if (phone.isEmpty) {
      _showError('Phone number is required');
      return;
    }
    if (country.isEmpty) {
      _showError('Country is required');
      return;
    }
    if (city.isEmpty) {
      _showError('City is required');
      return;
    }
    if (password.isEmpty) {
      _showError('Password is required');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    // ━━━━━ 2. PREVENT DUPLICATE SUBMISSIONS ━━━━━
    if (_isLoading) return;
    if (!mounted) return;

    // ━━━━━ 3. CLEAR PREVIOUS ERRORS ━━━━━
    ScaffoldMessenger.of(context).clearSnackBars();

    // ━━━━━ 4. SHOW LOADING STATE ━━━━━
    setState(() => _isLoading = true);

    try {
      // ━━━━━ 5. CALL REPOSITORY ━━━━━
      final result = await _authRepo.registerVolunteer(
        name: name,
        email: email,
        phone: phone,
        country: country,
        city: city,
        password: password,
      );

      // ━━━━━ 6. CHECK IF WIDGET STILL MOUNTED ━━━━━
      if (!mounted) return;
      setState(() => _isLoading = false);

      // ━━━━━ 7. HANDLE RESULT ━━━━━
      if (result.isSuccess) {
        // Registration successful - show success message and navigate
        _showSuccess('Registration successful! Please log in.');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/login');
      } else {
        // Registration failed - show specific error
        _showError(result.errorMessage ?? 'Registration failed.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Unexpected error: $e');
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  /// Shows error snackbar
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows success snackbar
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Join as Volunteer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Make an impact in your community',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // ━━━━━ NAME FIELD ━━━━━
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'John Doe',
                icon: Icons.person_outlined,
              ),
              const SizedBox(height: 16),

              // ━━━━━ EMAIL FIELD ━━━━━
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'john@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // ━━━━━ PHONE FIELD ━━━━━
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ━━━━━ COUNTRY & CITY ━━━━━
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      hint: 'United States',
                      icon: Icons.public,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'New York',
                      icon: Icons.location_city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ━━━━━ PASSWORD FIELD ━━━━━
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // ━━━━━ REGISTER BUTTON ━━━━━
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ━━━━━ LOGIN LINK ━━━━━
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.go('/login'),
                    child: const Text('Log in'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

---

## Key Safety Patterns Used

### 1. **Input Validation First**
```dart
if (email.isEmpty) {
  _showError('Email is required');
  return; // ← Early return, don't proceed
}

if (!_isValidEmail(email)) {
  _showError('Invalid email format');
  return;
}
```

### 2. **Prevent Duplicate Submissions**
```dart
// Check if already loading
if (_isLoading) return;

// Disable button while loading
onPressed: _isLoading ? null : _handleRegister,

// Show loading spinner
child: _isLoading
    ? CircularProgressIndicator()
    : Text('Register'),
```

### 3. **Clear Previous Errors**
```dart
// Always clear before showing new error
ScaffoldMessenger.of(context).clearSnackBars();

// Then show new error
ScaffoldMessenger.of(context).showSnackBar(...);
```

### 4. **Check Mounted After Async**
```dart
await _authRepo.signIn(...); // Async operation

// Check if widget still exists
if (!mounted) return;
setState(() => _isLoading = false); // Safe to call now
```

### 5. **Use Result Object Instead of Exceptions**
```dart
// Repository returns result, never throws
final result = await _authRepo.signIn(email: email, password: password);

// No try-catch needed for expected errors
if (result.isSuccess) {
  // Handle success
} else {
  _showError(result.errorMessage);
}
```

---

## Testing This Code

```dart
// Test 1: Empty email
// Action: Leave email empty, click Register
// Expected: Shows "Email is required"

// Test 2: Invalid email
// Action: Enter "john" (no @), click Register
// Expected: Shows "Please enter a valid email address"

// Test 3: Short password
// Action: Enter "ab" as password, click Register
// Expected: Shows "Password must be at least 6 characters"

// Test 4: Duplicate click
// Action: Click Register, then quickly click again before loading completes
// Expected: Second click does nothing (button disabled)

// Test 5: Successful registration
// Action: Enter valid data, click Register
// Expected: Loading spinner appears, then "Registration successful!" and navigates to login

// Test 6: Network error
// Action: Turn off internet before clicking Register
// Expected: Shows network error message

// Test 7: Email already exists
// Action: Register with same email twice
// Expected: Second attempt shows "Email already registered"
```
