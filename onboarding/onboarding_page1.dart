import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/onboarding_style.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: OnboardingStyle.backgroundGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              flex: 5,
              child: Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/icons/onboarding1.png',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 180),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mother Health Tracking',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: OnboardingStyle.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create a mother profile and easily monitor health records including BP, glucose, weight and history in one secure place.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
