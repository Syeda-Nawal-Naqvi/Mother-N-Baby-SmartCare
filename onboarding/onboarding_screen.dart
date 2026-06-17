import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';
import 'onboarding_page4.dart';
import 'onboarding_page5.dart';
import 'onboarding_page6.dart';
import '../../utils/onboarding_style.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = const [
    OnboardingPage1(),
    OnboardingPage2(),
    OnboardingPage3(),
    OnboardingPage4(),
    OnboardingPage5(),
    OnboardingPage6(),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingStyle.babyPink,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Pages ───────────────────────────────────────────────
            PageView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);

                // Last page pe 1.5s baad automatically login
                if (index == _pages.length - 1) {
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted && _currentPage == _pages.length - 1) {
                      _finishOnboarding();
                    }
                  });
                }
              },
              children: _pages,
            ),

            // ── Skip Button ──────────────────────────────────────────
            Positioned(
              top: 10,
              right: 16,
              child: AnimatedOpacity(
                opacity: _currentPage == _pages.length - 1 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: OnboardingStyle.primaryPink,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),

            // ── Dots ────────────────────────────────────────────────
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? OnboardingStyle.primaryPink
                          : OnboardingStyle.primaryPink.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
