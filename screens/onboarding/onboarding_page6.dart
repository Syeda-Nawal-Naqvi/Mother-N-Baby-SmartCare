import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/onboarding_style.dart';

class OnboardingPage6 extends StatelessWidget {
  const OnboardingPage6({super.key});

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
                child: OnboardingStyle.roundedImage(
                  'assets/icons/onboarding6.png',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 180),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cloud Sync & Security',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: OnboardingStyle.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Keep your health records securely stored and synchronized through the cloud. Access your data safely across devices anytime while ensuring full protection of your information.',
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
