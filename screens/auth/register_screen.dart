import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'verify_email_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _adminCodeCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isAdminRegister = false;
  String _selectedRole = 'mother';
  String? _errorMessage;

  // shipping to production — a hardcoded string can be read out of the APK.
  static const String _adminInviteCode = 'myapp_admin';

  final List<Map<String, String>> _roles = [
    {'value': 'mother', 'label': 'Mother', 'icon': 'assets/icons/mother.png'},
    {'value': 'father', 'label': 'Father', 'icon': 'assets/icons/father.png'},
    {
      'value': 'caretaker',
      'label': 'Caretaker',
      'icon': 'assets/icons/caretaker.png'
    },
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _adminCodeCtrl.dispose();
    super.dispose();
  }

  void _showToast(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateByRole(String role) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String roleToRegister = _selectedRole;

    if (_isAdminRegister) {
      if (_adminCodeCtrl.text.trim() != _adminInviteCode) {
        setState(() => _isLoading = false);
        _showToast('Invalid admin invite code.', isSuccess: false);
        return;
      }
      roleToRegister = 'admin';
    }

    final error = await _authService.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      role: roleToRegister,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);
    _showToast('Account created! Please verify your email 📧', isSuccess: true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
    );
  }

  Future<void> _googleRegister() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    _showToast('Opening Google Sign-In…', isSuccess: true);

    final result = await _authService.signInWithGoogle(
      defaultRole: _selectedRole,
    );

    if (!mounted) return;

    if (result['error'] != null) {
      setState(() {
        _errorMessage = result['error'];
        _isGoogleLoading = false;
      });
      return;
    }

    setState(() => _isGoogleLoading = false);
    _showToast('Google signup successful! Welcome 🎉', isSuccess: true);
    _navigateByRole(result['role']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF3D1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE91E8C)
                                  .withValues(alpha: 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/create_account.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3D1A2E)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join SmartCare family today',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.red.shade700),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _errorMessage = null),
                          child: Icon(Icons.close,
                              color: Colors.red.shade300, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (!_isAdminRegister) ...[
                  _buildLabel('I am a'),
                  const SizedBox(height: 10),
                  Row(
                    children: _roles.map((role) {
                      final isSelected = _selectedRole == role['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedRole = role['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE91E8C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE91E8C)
                                    : Colors.pink.shade100,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE91E8C)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Image.asset(role['icon']!,
                                    width: 28, height: 28),
                                const SizedBox(height: 6),
                                Text(
                                  role['label']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF3D1A2E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _isAdminRegister = !_isAdminRegister),
                    icon: Icon(
                      _isAdminRegister
                          ? Icons.close_rounded
                          : Icons.admin_panel_settings_outlined,
                      size: 18,
                      color: const Color(0xFFE91E8C),
                    ),
                    label: Text(
                      _isAdminRegister
                          ? 'Cancel admin signup'
                          : 'Register as Admin',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE91E8C)),
                    ),
                  ),
                ),
                if (_isAdminRegister) ...[
                  _buildLabel('Admin Invite Code'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _adminCodeCtrl,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: _inputDecoration(
                        hint: 'Enter invite code', icon: Icons.key_outlined),
                    validator: (v) {
                      if (_isAdminRegister && (v == null || v.trim().isEmpty)) {
                        return 'Invite code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 16),
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _inputDecoration(
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _inputDecoration(
                      hint: 'Enter your email',
                      icon: Icons.mail_outline_rounded),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v.trim())) {
                      {
                        return 'Enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildLabel('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.poppins(fontSize: 14),
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                    hint: 'Min. 6 characters',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters required';
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) {
                      return 'Include at least one uppercase letter';
                    }
                    if (!RegExp(r'(?=.*[0-9])').hasMatch(v)) {
                      return 'Include at least one number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildPasswordStrength(_passwordCtrl.text),
                const SizedBox(height: 18),
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: _inputDecoration(
                    hint: 'Re-enter your password',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor:
                          const Color(0xFFE91E8C).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text('Create Account',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.pink.shade100)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: Colors.pink.shade100)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _googleRegister,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.pink.shade100, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isGoogleLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.pink.shade300, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icons/google.png',
                                  width: 22, height: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3D1A2E)),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey.shade600)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE91E8C)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;
    if (password.length >= 6) strength++;
    if (RegExp(r'(?=.*[A-Z])').hasMatch(password)) strength++;
    if (RegExp(r'(?=.*[0-9])').hasMatch(password)) strength++;
    if (RegExp(r'(?=.*[!@#\$&*~])').hasMatch(password)) strength++;

    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      Colors.transparent,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.blue.shade400,
      Colors.green.shade500,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                height: 4,
                decoration: BoxDecoration(
                  color: i < strength ? colors[strength] : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          'Password strength: ${labels[strength]}',
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: colors[strength],
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D1A2E)));
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: const Color(0xFFE91E8C), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.pink.shade100)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
    );
  }
}
