import 'package:flutter/material.dart';

class OrganizationSignupScreen extends StatefulWidget {
  const OrganizationSignupScreen({super.key});

  @override
  State<OrganizationSignupScreen> createState() => _OrganizationSignupScreenState();
}

class _OrganizationSignupScreenState extends State<OrganizationSignupScreen> {
  final _orgNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Join GIVV',
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image/Gradient as seen in Figma
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&q=80&w=1000'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Organization Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 24),
                  _buildField('Organization Name', 'Enter legal organization name', _orgNameController, Icons.business),
                  _buildField('Government Registration Number', 'Reg # 12345678', _regNumberController, Icons.badge_outlined),
                  _buildField('Official Email', 'org@email.com', _emailController, Icons.email_outlined),
                  _buildField('Phone Number', '+1 (555) 000-0000', _phoneController, Icons.phone_outlined),
                  
                  Row(
                    children: [
                      Expanded(child: _buildField('Country', 'Select', _countryController, Icons.public, isDropdown: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField('City', 'City', _cityController, Icons.location_city)),
                    ],
                  ),
                  
                  _buildField('Password', 'Min 8 characters', _passwordController, Icons.lock_outline, isPassword: true),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Register Organization', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.volunteer_activism, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: Color(0xFF6B7280))),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Log in', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
              suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)) : (isPassword ? const Icon(Icons.visibility_off_outlined, color: Color(0xFF9CA3AF), size: 18) : null),
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
