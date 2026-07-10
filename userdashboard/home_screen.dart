import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  bool _isLoading = true;
  int _pressedIndex = -1;
  bool _drawerOpen = false;

  AnimationController? _drawerController;
  Animation<double>? _drawerAnim;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerAnim = CurvedAnimation(
      parent: _drawerController!,
      curve: Curves.easeInOut,
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _drawerController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!mounted) return;
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = _auth.currentUser?.displayName ??
              _auth.currentUser?.email?.split('@')[0] ??
              'User';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = _auth.currentUser?.email?.split('@')[0] ?? 'User';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserName() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!mounted) return;
      if (doc.exists) setState(() => _userName = doc['name'] ?? _userName);
    } catch (_) {}
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 20) return 'Good Evening';
    return 'Good Night';
  }

  String get _motivationalQuote {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with care and love 🌸';
    if (hour < 17) return "You're doing amazing — keep going! 💪";
    return "Wonderful to have you here tonight 🌙";
  }

  void _toggleDrawer() {
    setState(() => _drawerOpen = !_drawerOpen);
    if (_drawerOpen) {
      _drawerController?.forward();
    } else {
      _drawerController?.reverse();
    }
  }

  void _closeDrawer() {
    if (_drawerOpen) {
      setState(() => _drawerOpen = false);
      _drawerController?.reverse();
    }
  }

  Future<void> _goToProfile() async {
    _closeDrawer();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await Navigator.pushNamed(context, '/profile');
    if (mounted) await _refreshUserName();
  }

  // Fix: capture navigator before async gap
  Future<void> _goToSettings() async {
    _closeDrawer();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushNamed(context, '/settings');
  }

  Future<void> _logout() async {
    _closeDrawer();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Sign out',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    // Guard after showDialog await
    if (!mounted) return;

    if (confirm == true) {
      await _authService.logout();
      // Guard after logout await
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateToRoute(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Mother Health\nTracker',
        'icon': 'assets/icons/onboarding1.png',
        'color': const Color(0xFFE91E8C),
        'light': const Color(0xFFFFE4F2),
        'route': '/mother_tracker',
      },
      {
        'title': 'Baby Health\nTracker',
        'icon': 'assets/icons/baby.png',
        'color': const Color(0xFF3B82F6),
        'light': const Color(0xFFDBEAFE),
        'route': '/baby_tracker',
      },
      {
        'title': 'Records &\nGraphs',
        'icon': 'assets/icons/records.png',
        'color': const Color(0xFF10B981),
        'light': const Color(0xFFD1FAE5),
        'route': '/records',
      },
      {
        'title': 'Reminders',
        'icon': 'assets/icons/reminder.png',
        'color': const Color(0xFFF59E0B),
        'light': const Color(0xFFFEF3C7),
        'route': '/reminders',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Stack(
        children: [
          // ── Main Content ───────────────────────────────────────────────
          GestureDetector(
            onTap: _closeDrawer,
            child: AnimatedOpacity(
              opacity: _drawerOpen ? 0.35 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: AbsorbPointer(
                absorbing: _drawerOpen,
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFE91E8C)),
                      )
                    : SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Top Bar ──────────────────────────
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pink.shade100,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/icons/app_logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.favorite_rounded,
                                        color: Color(0xFFE91E8C),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mother N Baby',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFE91E8C),
                                        ),
                                      ),
                                      Text(
                                        'SmartCare',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFE91E8C),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Hamburger
                                  GestureDetector(
                                    onTap: _toggleDrawer,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.pink.shade100,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildMenuLine(wide: true),
                                          const SizedBox(height: 4),
                                          _buildMenuLine(wide: false),
                                          const SizedBox(height: 4),
                                          _buildMenuLine(wide: true),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // ── Greeting Card ─────────────────────
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE91E8C),
                                      Color(0xFFFF6EB4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE91E8C)
                                          .withValues(alpha: 0.28),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greeting,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white
                                            .withValues(alpha: 0.80),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _userName.isNotEmpty
                                          ? _userName
                                          : 'Welcome!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _motivationalQuote,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ── Health Modules ────────────────────
                              Text(
                                'Health Modules',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3D1A2E),
                                ),
                              ),

                              const SizedBox(height: 16),

                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.95,
                                ),
                                itemCount: modules.length,
                                itemBuilder: (context, index) {
                                  final m = modules[index];
                                  return _buildModuleCard(
                                    index: index,
                                    title: m['title'] as String,
                                    iconPath: m['icon'] as String,
                                    color: m['color'] as Color,
                                    lightColor: m['light'] as Color,
                                    route: m['route'] as String,
                                  );
                                },
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // ── Side Drawer ────────────────────────────────────────────────
          if (_drawerAnim != null)
            AnimatedBuilder(
              animation: _drawerAnim!,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 260 * _drawerAnim!.value,
                  child: child!,
                );
              },
              child: Material(
                elevation: 20,
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menu',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3D1A2E),
                              ),
                            ),
                            GestureDetector(
                              onTap: _closeDrawer,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 18, color: Color(0xFFE91E8C)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey.shade100),
                        const SizedBox(height: 20),

                        // Profile item
                        _buildDrawerItem(
                          iconPath: 'assets/icons/profile.png',
                          iconBg: const Color(0xFFFFE4F2),
                          label: 'Profile',
                          onTap: _goToProfile,
                        ),
                        const SizedBox(height: 14),

                        // Settings item — uses extracted async method
                        _buildDrawerItem(
                          iconPath: 'assets/icons/settings.png',
                          iconBg: const Color(0xFFDBEAFE),
                          label: 'Settings',
                          onTap: _goToSettings,
                        ),

                        const Spacer(),
                        Divider(color: Colors.grey.shade100),
                        const SizedBox(height: 14),

                        // Logout item
                        _buildDrawerItem(
                          iconPath: 'assets/icons/logout.png',
                          iconBg: const Color(0xFFFFEBEE),
                          label: 'Sign out',
                          labelColor: Colors.red.shade400,
                          onTap: _logout,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────

  Widget _buildMenuLine({required bool wide}) {
    return Container(
      width: wide ? 18 : 12,
      height: 2,
      decoration: BoxDecoration(
        color: const Color(0xFFE91E8C),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String iconPath,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: iconBg.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconBg.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_outline_rounded,
                  color: labelColor ?? const Color(0xFFE91E8C),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor ?? const Color(0xFF3D1A2E),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: (labelColor ?? const Color(0xFFE91E8C))
                  .withValues(alpha: 0.45),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required int index,
    required String title,
    required String iconPath,
    required Color color,
    required Color lightColor,
    required String route,
  }) {
    final isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedIndex = index),
      onTapUp: (_) {
        setState(() => _pressedIndex = -1);
        // No async gap — safe to use context directly
        _navigateToRoute(route);
      },
      onTapCancel: () => setState(() => _pressedIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()
          ..scaleByDouble(
            isPressed ? 0.94 : 1.0,
            isPressed ? 0.94 : 1.0,
            1.0,
            1.0,
          ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPressed ? lightColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isPressed
                  ? color.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.10),
              blurRadius: isPressed ? 20 : 14,
              offset: isPressed ? const Offset(0, 8) : const Offset(0, 4),
              spreadRadius: isPressed ? 2 : 0,
            ),
          ],
          border: Border.all(
            color:
                isPressed ? color.withValues(alpha: 0.35) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: isPressed ? 72 : 66,
                  height: isPressed ? 72 : 66,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        isPressed ? color.withValues(alpha: 0.15) : lightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.health_and_safety_rounded,
                      color: color,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPressed ? color : const Color(0xFF3D1A2E),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
