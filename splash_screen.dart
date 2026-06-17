import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _loadingController;

  late Animation<double> _fadeAnim;
  late Animation<double> _loadingAnim;

  final String mainQuote = 'Every new beginning\nis filled with love!';

  final String subQuote = "Let's walk this beautiful journey\ntogether";

  @override
  void initState() {
    super.initState();

    // Preload background image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/splash_bg.jpg'),
        context,
      );
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    _loadingAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    _startSequence();
  }

  void _startSequence() async {
    _fadeController.forward();
    _loadingController.forward();

    await Future.delayed(
      const Duration(milliseconds: 6000),
    );

    if (mounted) {
      _navigate();
    }
  }

  void _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE8EF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            errorBuilder: (_, __, ___) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFDE8EF),
                      Color(0xFFF9C8D8),
                      Color(0xFFF5B8CC),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xEEFDE8EF),
                  Color(0xAAF9C8D8),
                  Color(0x44F5B8CC),
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    'Mom N Baby SmartCare',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE91E8C),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Text(
                          mainQuote,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromARGB(255, 134, 2, 75),
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                subQuote,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF5C3040),
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '❤️',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    'loading...',
                    style: GoogleFonts.dancingScript(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD81B6A).withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 90,
                    ),
                    child: AnimatedBuilder(
                      animation: _loadingAnim,
                      builder: (_, __) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _loadingAnim.value,
                            backgroundColor:
                                Colors.pink.shade100.withValues(alpha: 0.6),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFE91E8C),
                            ),
                            minHeight: 3,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
