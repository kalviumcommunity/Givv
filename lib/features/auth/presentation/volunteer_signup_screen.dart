import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';

class VolunteerSignupScreen extends StatefulWidget {
  const VolunteerSignupScreen({super.key});

  @override
  State<VolunteerSignupScreen> createState() => _VolunteerSignupScreenState();
}

class _VolunteerSignupScreenState extends State<VolunteerSignupScreen> {
  final _authRepo = AuthRepository();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    // Comprehensive validation
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final country = _countryController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text;
    final inviteCode = _inviteCodeController.text.trim();

    if (name.isEmpty) {
      _showSnackbar('Full name is required.');
      return;
    }
    if (email.isEmpty) {
      _showSnackbar('Email address is required.');
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnackbar('Please enter a valid email address.');
      return;
    }
    if (phone.isEmpty) {
      _showSnackbar('Phone number is required.');
      return;
    }
    if (country.isEmpty) {
      _showSnackbar('Country is required.');
      return;
    }
    if (city.isEmpty) {
      _showSnackbar('City is required.');
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('Password is required.');
      return;
    }
    if (password.length < 6) {
      _showSnackbar('Password must be at least 6 characters.');
      return;
    }

    // Clear any previous snackbars to prevent duplicates
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    // Start loading
    setState(() => _isLoading = true);

    try {
      // Perform registration
      final result = await _authRepo.registerVolunteer(
        name: name,
        email: email,
        phone: phone,
        country: country,
        city: city,
        password: password,
        organizationCode: inviteCode,
      );

      // Check if widget is still mounted before updating state
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        // Registration successful
        _showSnackbar('Account created! Please log in.', isSuccess: true);
        
        // Navigate after a brief delay to allow user to see success message
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/login');
      } else {
        // Registration failed - show error message from repository
        _showSnackbar(result.errorMessage ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      // Unexpected error - should not happen with proper error handling
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  /// Shows a snackbar with the given message.
  /// Previous snackbars are cleared to prevent duplicates.
  /// [isSuccess] determines if the snackbar is styled as success (true) or error (false).
  void _showSnackbar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF6794AA) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: isSuccess ? const Duration(seconds: 2) : const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6794AA);
    const textColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Volunteer Signup',
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: Column(
            children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.volunteer_activism,
                  size: 32, color: primaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'GIVV',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor),
            ),
            const Text(
              'Join the movement. Make an impact.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 40),

            _buildField('Full Name', 'John Doe', _nameController,
                Icons.person_outline),
            _buildField('Email Address', 'john@example.com', _emailController,
                Icons.email_outlined),
            _buildField('Phone Number', '+1 (555) 000-0000',
                _phoneController, Icons.phone_outlined),

            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFieldCompact('Country', 'United States',
                        _countryController, Icons.public),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFieldCompact('City', 'New York', _cityController,
                        Icons.location_city),
                  ),
                ),
              ],
            ),

            _buildField('Create Password', '••••••••', _passwordController,
                Icons.lock_outline,
                isPassword: true),

            const Divider(
                height: 48, thickness: 1, color: Color(0xFFF3F4F6)),

            _buildField(
                'Organization Invite Code',
                'ENTER CODE (E.G. GIVV-2024)',
                _inviteCodeController,
                Icons.group_add_outlined),

            const SizedBox(height: 24),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Join Organization',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
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

  Widget _buildFieldCompact(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          key: ValueKey(label.toLowerCase().replaceAll(RegExp(r'\s+'), '_')),
          obscureText: isPassword && _obscurePassword,
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : (label.toLowerCase().contains('email')
                  ? TextInputType.emailAddress
                  : (label.toLowerCase().contains('phone')
                      ? TextInputType.phone
                      : TextInputType.text)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon:
                Icon(icon, color: const Color(0xFF9CA3AF), size: 18),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF6794AA), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            key: ValueKey(label.toLowerCase().replaceAll(RegExp(r'\s+'), '_')),
            obscureText: isPassword && _obscurePassword,
            keyboardType: isPassword
                ? TextInputType.visiblePassword
                : (label.toLowerCase().contains('email')
                    ? TextInputType.emailAddress
                    : (label.toLowerCase().contains('phone')
                        ? TextInputType.phone
                        : TextInputType.text)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              prefixIcon:
                  Icon(icon, color: const Color(0xFF9CA3AF), size: 18),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF6794AA), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
