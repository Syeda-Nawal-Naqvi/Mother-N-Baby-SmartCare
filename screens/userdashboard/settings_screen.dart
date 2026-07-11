import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../auth/forgot_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  void _showToast(String message, {required bool isSuccess}) {
    if (!mounted) return;
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
              child: Text(message,
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
            ),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF10B981) : const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Change password ───────────────────────────────────────────────────
  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeNotifier>().isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A1A2E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Change Password',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF3D1A2E),
              )),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                    ctrl: currentCtrl,
                    hint: 'Current password',
                    isPassword: true,
                    isDark: isDark),
                const SizedBox(height: 12),
                _dialogField(
                    ctrl: newCtrl,
                    hint: 'New password',
                    isPassword: true,
                    isDark: isDark),
                const SizedBox(height: 12),
                _dialogField(
                    ctrl: confirmCtrl,
                    hint: 'Confirm new password',
                    isPassword: true,
                    isDark: isDark),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()));
                    },
                    child: Text('Forgot your password?',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE91E8C))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey.shade400 : Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  _showToast('Passwords do not match', isSuccess: false);
                  return;
                }
                if (newCtrl.text.length < 6) {
                  _showToast('Minimum 6 characters required', isSuccess: false);
                  return;
                }
                final error = await _authService.changePassword(
                  oldPassword: currentCtrl.text,
                  newPassword: newCtrl.text,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (error == null) {
                  _showToast('Password updated successfully!', isSuccess: true);
                } else {
                  _showToast(error, isSuccess: false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Update',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ── Change email ──────────────────────────────────────────────────────
  Future<void> _changeEmail() async {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeNotifier>().isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A1A2E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Change Email',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF3D1A2E))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'A verification link will be sent to your new email. Your email updates only after you click that link.',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                _dialogField(
                    ctrl: emailCtrl, hint: 'New email address', isDark: isDark),
                const SizedBox(height: 12),
                _dialogField(
                    ctrl: passwordCtrl,
                    hint: 'Current password',
                    isPassword: true,
                    isDark: isDark),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey.shade400 : Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  _showToast('Enter a valid email', isSuccess: false);
                  return;
                }
                if (passwordCtrl.text.isEmpty) {
                  _showToast('Enter your current password', isSuccess: false);
                  return;
                }
                final error = await _authService.requestEmailChange(
                    email, passwordCtrl.text);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (error == null) {
                  _showToast(
                      'Verification link sent to $email. Click it to confirm.',
                      isSuccess: true);
                } else {
                  _showToast(error, isSuccess: false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Send Link',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ── Send feedback ─────────────────────────────────────────────────────
  Future<void> _sendFeedback() async {
    final feedbackCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeNotifier>().isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A1A2E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Send Feedback',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF3D1A2E))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Share your thoughts or report an issue.',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600)),
              const SizedBox(height: 14),
              TextField(
                controller: feedbackCtrl,
                maxLines: 4,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF3D1A2E)),
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  filled: true,
                  fillColor:
                      isDark ? const Color(0xFF3D1A3A) : Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF6B2D5E)
                            : Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF6B2D5E)
                            : Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE91E8C), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey.shade400 : Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (feedbackCtrl.text.trim().isEmpty) {
                  _showToast('Please enter a message', isSuccess: false);
                  return;
                }
                try {
                  final uid = _auth.currentUser?.uid ?? '';
                  await _firestore.collection('feedback').add({
                    'userId': uid,
                    'userEmail': _auth.currentUser?.email ?? '',
                    'message': feedbackCtrl.text.trim(),
                    'status': 'pending',
                    'adminReply': null,
                    'createdAt': FieldValue.serverTimestamp(),
                    'repliedAt': null,
                    'notificationRead': false,
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _showToast("Feedback sent! We'll get back to you.",
                      isSuccess: true);
                } catch (_) {
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _showToast('Failed to send feedback.', isSuccess: false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  Text('Send', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ── Delete account ────────────────────────────────────────────────────
  Future<void> _deleteAccount() async {
    final passwordCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeNotifier>().isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A1A2E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Account',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.red.shade600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This is permanent and cannot be undone. All your data will be deleted.',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              _dialogField(
                  ctrl: passwordCtrl,
                  hint: 'Enter password to confirm',
                  isPassword: true,
                  isDark: isDark),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey.shade400 : Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showToast('Incorrect password. Try again.', isSuccess: false);
    }
  }

  Widget _dialogField({
    required TextEditingController ctrl,
    required String hint,
    bool isPassword = false,
    bool isDark = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      style: GoogleFonts.poppins(
          fontSize: 14, color: isDark ? Colors.white : const Color(0xFF3D1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        filled: true,
        fillColor: isDark ? const Color(0xFF3D1A3A) : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? const Color(0xFF6B2D5E) : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? const Color(0xFF6B2D5E) : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE91E8C), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.isDarkMode;

    const lightBg = Color(0xFFFFF0F5);
    const lightCard = Colors.white;
    const lightTitle = Color(0xFF3D1A2E);
    const lightSubtitle = Color(0xFF9E9E9E);
    const lightDivider = Color(0xFFF5F5F5);
    const darkBg = Color(0xFF1A0D1E);
    const darkCard = Color(0xFF2A1A2E);
    const darkTitle = Color(0xFFF5E6F5);
    const darkSubtitle = Color(0xFFB08AB8);
    const darkDivider = Color(0xFF3D1A3A);
    const darkSectionLabel = Color(0xFFE91E8C);

    final bgColor = isDark ? darkBg : lightBg;
    final cardColor = isDark ? darkCard : lightCard;
    final titleColor = isDark ? darkTitle : lightTitle;
    final subtitleColor = isDark ? darkSubtitle : lightSubtitle;
    final dividerColor = isDark ? darkDivider : lightDivider;
    final sectionLabelColor = isDark ? darkSectionLabel : Colors.grey.shade500;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? const Color(0xFFE91E8C) : const Color(0xFF3D1A2E),
              size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: titleColor)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Account', color: sectionLabelColor),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.mail_outline_rounded,
                      iconBg: isDark
                          ? const Color(0xFF1A2A4A)
                          : const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF3B82F6),
                      label: 'Change Email',
                      subtitle: 'Verify a new email address',
                      onTap: _changeEmail,
                      cardColor: cardColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      iconBg: isDark
                          ? const Color(0xFF2A2010)
                          : const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Change Password',
                      subtitle: 'Update or reset your password',
                      onTap: _changePassword,
                      cardColor: cardColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      icon: Icons.feedback_outlined,
                      iconBg: isDark
                          ? const Color(0xFF0A2A1A)
                          : const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF10B981),
                      label: 'Send Feedback',
                      subtitle: 'Tell us what you think',
                      onTap: _sendFeedback,
                      cardColor: cardColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Preferences', color: sectionLabelColor),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFF4A1A4A), width: 1)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFFE91E8C)
                                    .withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.07),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Notifications',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: titleColor)),
                            subtitle: Text('Reminders and health alerts',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: subtitleColor)),
                            secondary: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E8C)
                                    .withValues(alpha: isDark ? 0.15 : 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  color: Color(0xFFE91E8C), size: 20),
                            ),
                            value: _notificationsEnabled,
                            // activeColor replaced by activeThumbColor
                            activeThumbColor: const Color(0xFFE91E8C),
                            inactiveThumbColor: isDark
                                ? const Color(0xFF6B3A6B)
                                : Colors.grey.shade400,
                            inactiveTrackColor: isDark
                                ? const Color(0xFF3D1A3A)
                                : Colors.grey.shade200,
                            onChanged: (val) async {
                              setState(() => _notificationsEnabled = val);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('notifications_enabled', val);
                            },
                          ),
                          Divider(color: dividerColor),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Dark Mode',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: titleColor)),
                            subtitle: Text('Switch app theme',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: subtitleColor)),
                            secondary: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: isDark ? 0.20 : 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode
                                    : Icons.dark_mode_outlined,
                                color: isDark
                                    ? const Color(0xFFB39DDB)
                                    : const Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            value: themeNotifier.isDarkMode,
                            // activeColor replaced by activeThumbColor
                            activeThumbColor: const Color(0xFFE91E8C),
                            inactiveThumbColor: isDark
                                ? const Color(0xFF6B3A6B)
                                : Colors.grey.shade400,
                            inactiveTrackColor: isDark
                                ? const Color(0xFF3D1A3A)
                                : Colors.grey.shade200,
                            onChanged: (val) => themeNotifier.toggleTheme(val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Danger Zone', color: sectionLabelColor),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.delete_outline_rounded,
                      iconBg: isDark
                          ? const Color(0xFF2A0A0A)
                          : const Color(0xFFFFEBEE),
                      iconColor: Colors.red.shade400,
                      label: 'Delete Account',
                      subtitle: 'Permanently remove all data',
                      onTap: _deleteAccount,
                      labelColor: Colors.red.shade500,
                      cardColor: cardColor,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: Text(
                        'Mother N Baby SmartCare  ·  v1.0.0',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF6B3A6B)
                                : Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String label, {required Color color}) {
    return Text(label.toUpperCase(),
        style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.0));
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required bool isDark,
    Color? labelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: const Color(0xFF4A1A4A), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFFE91E8C).withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: labelColor ?? titleColor)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: subtitleColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isDark ? const Color(0xFF6B3A6B) : Colors.grey.shade300,
                size: 22),
          ],
        ),
      ),
    );
  }
}
