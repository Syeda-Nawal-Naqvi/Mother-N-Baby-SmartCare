// ─────────────────────────────────────────────────────────────────────────────
// stub_screens.dart  —  Temporary placeholder screens for module routes
// Replace each class body with your real implementation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Mother Tracker ────────────────────────────────────────────────────────────
class MotherTrackerScreen extends StatelessWidget {
  const MotherTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) => _StubScreen(
        title: 'Mother Health Tracker',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE91E8C),
        lightColor: const Color(0xFFFFE4F2),
      );
}

// ── Baby Tracker ──────────────────────────────────────────────────────────────
class BabyTrackerScreen extends StatelessWidget {
  const BabyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) => _StubScreen(
        title: 'Baby Health Tracker',
        icon: Icons.child_care_rounded,
        color: const Color(0xFF3B82F6),
        lightColor: const Color(0xFFDBEAFE),
      );
}

// ── Records & Graphs ──────────────────────────────────────────────────────────
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) => _StubScreen(
        title: 'Records & Graphs',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFF10B981),
        lightColor: const Color(0xFFD1FAE5),
      );
}

// ── Reminders ─────────────────────────────────────────────────────────────────
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) => _StubScreen(
        title: 'Reminders',
        icon: Icons.alarm_rounded,
        color: const Color(0xFFF59E0B),
        lightColor: const Color(0xFFFEF3C7),
      );
}

// ── Shared stub widget ────────────────────────────────────────────────────────
class _StubScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _StubScreen({
    required this.title,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

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
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3D1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3D1A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon — replace with real implementation.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
