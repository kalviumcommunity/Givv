import 'package:flutter/material.dart';

class VolunteerSignupScreen extends StatefulWidget {
  const VolunteerSignupScreen({super.key});

  @override
  State<VolunteerSignupScreen> createState() => _VolunteerSignupScreenState();
}

class _VolunteerSignupScreenState extends State<VolunteerSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Volunteer Signup',
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.volunteer_activism, size: 32, color: primaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'GIVV',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const Text(
              'Join the movement. Make an impact.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 40),
            
            _buildField('Full Name', 'John Doe', _nameController, Icons.person_outline),
            _buildField('Email Address', 'john@example.com', _emailController, Icons.email_outlined),
            _buildField('Phone Number', '+1 (555) 000-0000', _phoneController, Icons.phone_outlined),
            
            Row(
              children: [
                Expanded(child: _buildField('Country', 'United States', _countryController, Icons.public, isDropdown: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('City', 'New York', _cityController, Icons.location_city)),
              ],
            ),
            
            _buildField('Create Password', '••••••••', _passwordController, Icons.lock_outline, isPassword: true),
            
            const Divider(height: 48, thickness: 1, color: Color(0xFFF3F4F6)),
            
            _buildField('Organization Invite Code', 'ENTER CODE (E.G. GIVV-2024)', _inviteCodeController, Icons.group_add_outlined),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Join Organization >',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ', style: TextStyle(color: Color(0xFF6B7280))),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Log in', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, IconData icon, {bool isPassword = false, bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 18),
              suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)) : (isPassword ? const Icon(Icons.visibility_outlined, color: Color(0xFF9CA3AF), size: 18) : null),
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
            ),
          ),
        ],
      ),
    );
  }
}
