// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _selectedRole = 'mother';
  String _createdAt = '';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _changed = false;

  // ✅ Full labels saved to Firestore exactly as shown
  final List<Map<String, String>> _roles = [
    {'value': 'mother', 'label': 'Mother'},
    {'value': 'father/husband', 'label': 'Father / Husband'},
    {'value': 'caretaker', 'label': 'Caretaker'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Load profile ───────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        if (mounted) {
          setState(() {
            _email = _auth.currentUser?.email ?? '';
            _name = _auth.currentUser?.displayName ??
                _auth.currentUser?.email?.split('@')[0] ??
                'User';
            _isLoading = false;
          });
        }
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!mounted) return;

      if (doc.exists) {
        final rawRole = doc['role'] ?? 'mother';
        // ✅ Normalise legacy 'father' → 'father/husband'
        final normalisedRole = rawRole == 'father' ? 'father/husband' : rawRole;

        setState(() {
          _name = doc['name'] ?? '';
          _email = _auth.currentUser?.email ?? '';
          _selectedRole = normalisedRole;
          final ts = doc['createdAt'];
          if (ts != null) {
            final dt = (ts as dynamic).toDate() as DateTime;
            _createdAt = '${dt.day}/${dt.month}/${dt.year}';
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _name = _auth.currentUser?.displayName ??
              _auth.currentUser?.email?.split('@')[0] ??
              'User';
          _email = _auth.currentUser?.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _name = _auth.currentUser?.displayName ??
              _auth.currentUser?.email?.split('@')[0] ??
              'User';
          _email = _auth.currentUser?.email ?? '';
          _isLoading = false;
        });
      }
    }
  }

  // ── Save a single field to Firestore ──────────────────────────────────
  Future<void> _saveField({
    required String field,
    required String value,
  }) async {
    if (value.trim().isEmpty) {
      _showToast('Field cannot be empty', isSuccess: false);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).set(
        {field: value.trim()},
        SetOptions(merge: true),
      );

      if (!mounted) return;
      setState(() {
        if (field == 'name') _name = value.trim();
        if (field == 'role') _selectedRole = value.trim();
        _isSaving = false;
        _changed = true;
      });
      _showToast('Updated successfully!', isSuccess: true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showToast('Failed to save. Try again.', isSuccess: false);
      }
    }
  }

  // ── Name edit dialog ───────────────────────────────────────────────────
  Future<void> _showNameDialog(bool isDark) async {
    final ctrl = TextEditingController(text: _name);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Name',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF5E6F5) : const Color(0xFF3D1A2E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Maximum 30 characters allowed.',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color:
                      isDark ? const Color(0xFFB08AB8) : Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLength: 30,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFF5E6F5)
                      : const Color(0xFF3D1A2E)),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: GoogleFonts.poppins(
                    color:
                        isDark ? const Color(0xFFB08AB8) : Colors.grey.shade400,
                    fontSize: 13),
                counterStyle: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFFB08AB8)
                        : Colors.grey.shade400),
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
              final value = ctrl.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(ctx);
              await _saveField(field: 'name', value: value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onEmailTap() {
    _showToast('To change email, go to Settings → Change Email',
        isSuccess: false);
  }

  void _showToast(String message, {required bool isSuccess}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.info_outline,
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
            isSuccess ? const Color(0xFF10B981) : const Color(0xFFE91E8C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String get _roleLabel {
    final found = _roles.firstWhere(
      (r) => r['value'] == _selectedRole,
      orElse: () => {'value': _selectedRole, 'label': _selectedRole},
    );
    return found['label'] ?? _selectedRole;
  }

  Color get _roleColor {
    switch (_selectedRole) {
      case 'mother':
        return const Color(0xFFE91E8C);
      case 'father/husband':
        return const Color(0xFF3B82F6);
      case 'caretaker':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFE91E8C);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.isDarkMode;

    final bgColor = isDark ? const Color(0xFF1A0D1E) : const Color(0xFFFFF0F5);
    final cardColor = isDark ? const Color(0xFF2A1A2E) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFF5E6F5) : const Color(0xFF3D1A2E);
    final textSecondary =
        isDark ? const Color(0xFFB08AB8) : Colors.grey.shade500;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? const Color(0xFFE91E8C) : const Color(0xFF3D1A2E),
              size: 20),
          onPressed: () => Navigator.pop(context, _changed),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  // ✅ Everything centered
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Title ──────────────────────────────────
                    Text(
                      'My Profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your personal information',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Avatar ─────────────────────────────────
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E8C), Color(0xFFFF6EB4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE91E8C).withValues(alpha: 0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Name + role badge ──────────────────────
                    Text(
                      _name.isNotEmpty ? _name : 'User',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _roleColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _roleColor.withValues(alpha: 0.30)),
                      ),
                      child: Text(
                        _roleLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _roleColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Section label ──────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _sectionLabel('ACCOUNT DETAILS', textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // ── Full Name card ─────────────────────────
                    _buildInfoCard(
                      label: 'FULL NAME',
                      accentColor: const Color(0xFF10B981),
                      cardColor: cardColor,
                      isDark: isDark,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _name.isNotEmpty ? _name : '—',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF10B981),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => _showNameDialog(isDark),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Color(0xFF10B981),
                                      size: 18,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Email card ─────────────────────────────
                    _buildInfoCard(
                      label: 'EMAIL ADDRESS',
                      accentColor: const Color(0xFFE91E8C),
                      cardColor: cardColor,
                      isDark: isDark,
                      child: GestureDetector(
                        onTap: _onEmailTap,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _email.isNotEmpty ? _email : '—',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Color(0xFFE91E8C),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Role card — dropdown ───────────────────
                    _buildInfoCard(
                      label: 'ROLE',
                      accentColor: const Color(0xFF3B82F6),
                      cardColor: cardColor,
                      isDark: isDark,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF3B82F6),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                          dropdownColor: cardColor,
                          items: _roles.map((role) {
                            return DropdownMenuItem<String>(
                              // ✅ value = 'father/husband' — saved exactly to DB
                              value: role['value'],
                              child: Text(
                                role['label']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value == null) return;
                            setState(() => _selectedRole = value);
                            // ✅ Saves 'father/husband' to Firestore — not just 'father'
                            await _saveField(field: 'role', value: value);
                          },
                        ),
                      ),
                    ),

                    if (_createdAt.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildInfoCard(
                        label: 'MEMBER SINCE',
                        accentColor: const Color(0xFF66BB6A),
                        cardColor: cardColor,
                        isDark: isDark,
                        child: Text(
                          _createdAt,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────────────────

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required Widget child,
    required Color accentColor,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF4A1A4A)
              : accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFFE91E8C).withValues(alpha: 0.04)
                : accentColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
