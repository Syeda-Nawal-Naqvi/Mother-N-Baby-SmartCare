import 'package:flutter/material.dart';
import '../../widgets/app_widgets.dart';
import 'baby_list_screen.dart';

/// Landing screen of the Baby Health Tracker module. Everything now lives
/// behind a baby profile: the user picks (or creates) a baby first, then
/// gets to that baby's own Weight / Vaccination / Milestone / Allergy /
/// Medical History sections, so records for different babies are always
/// kept separate.
class BabyHealthScreen extends StatelessWidget {
  const BabyHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Health Tracker')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const ModuleHeaderCard(
                  title: 'Baby Health Tracker',
                  subtitle:
                      'Create a baby profile to track growth, vaccinations, milestones, allergies and medical history',
                  icon: Icons.child_care_rounded,
                  color: ModuleColors.profile,
                ),
                const SizedBox(height: 20),
                HealthMenuTile(
                  title: 'Baby Profiles',
                  subtitle: 'View, add and manage your babies',
                  icon: Icons.family_restroom_rounded,
                  color: ModuleColors.profile,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BabyListScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
