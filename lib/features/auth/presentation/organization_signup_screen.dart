import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';

class OrganizationSignupScreen extends StatefulWidget {
  const OrganizationSignupScreen({super.key});

  @override
  State<OrganizationSignupScreen> createState() =>
      _OrganizationSignupScreenState();
}

class _OrganizationSignupScreenState extends State<OrganizationSignupScreen> {
  final _authRepo = AuthRepository();

  final _orgNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _orgNameController.dispose();
    _regNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    // Comprehensive validation
    final orgName = _orgNameController.text.trim();
    final regNumber = _regNumberController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final country = _countryController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text;

    if (orgName.isEmpty) {
      _showSnackbar('Organization name is required.');
      return;
    }
    if (regNumber.isEmpty) {
      _showSnackbar('Government registration number is required.');
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
      final result = await _authRepo.registerOrganization(
        orgName: orgName,
        registrationNumber: regNumber,
        email: email,
        phone: phone,
        country: country,
        city: city,
        password: password,
      );

      // Check if widget is still mounted before updating state
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        // Registration successful
        _showSnackbar('Organization registered! Please log in.', isSuccess: true);
        
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Join GIVV',
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image/Gradient
            Container(
              height: 180,
              width: double.infinity,
              margin:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&q=80&w=1000'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      primaryColor.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Register your\norganization\nto start making an impact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text(
                    'Organization Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  const SizedBox(height: 24),
                  _buildField('Organization Name', 'Enter legal organization name',
                      _orgNameController, Icons.business),
                  _buildField('Government Registration Number', 'Reg # 12345678',
                      _regNumberController, Icons.badge_outlined),
                  _buildField('Official Email', 'org@email.com',
                      _emailController, Icons.email_outlined),
                  _buildField('Phone Number', '+1 (555) 000-0000',
                      _phoneController, Icons.phone_outlined),

                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFieldCompact('Country', 'Select',
                              _countryController, Icons.public),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildFieldCompact(
                              'City', 'City', _cityController, Icons.location_city),
                        ),
                      ),
                    ],
                  ),

                  _buildField('Password', 'Min 8 characters',
                      _passwordController, Icons.lock_outline,
                      isPassword: true),

                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor:
                            primaryColor.withOpacity(0.6),
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Register Organization',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.volunteer_activism,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Row(
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
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                  ),
                ),
              ),
            ),
          ],
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
