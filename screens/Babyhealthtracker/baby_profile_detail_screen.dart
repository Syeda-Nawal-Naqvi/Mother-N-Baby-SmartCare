import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'allergy_screen.dart';
import 'baby_medical_history_screen.dart';
import 'baby_weight_screen.dart';
import 'milestone_screen.dart';
import 'vaccination_screen.dart';

/// Opened after tapping a baby profile. Every section below (Weight,
/// Vaccination, Milestones, Allergies, Medical History) is scoped to this
/// one baby via [babyId], so records for different babies never mix.
class BabyProfileDetailScreen extends StatelessWidget {
  final String babyId;
  final String babyName;
  const BabyProfileDetailScreen(
      {super.key, required this.babyId, required this.babyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(babyName)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ModuleHeaderCard(
                  title: babyName,
                  subtitle: 'Growth, vaccinations, milestones and allergies',
                  icon: Icons.child_care_rounded,
                  color: ModuleColors.profile,
                ),
                const SizedBox(height: 20),
                HealthMenuTile(
                  title: 'Weight',
                  subtitle: 'Track growth over time',
                  icon: Icons.monitor_weight_rounded,
                  color: ModuleColors.weight,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BabyWeightScreen(
                            babyId: babyId, babyName: babyName)),
                  ),
                ),
                HealthMenuTile(
                  title: 'Vaccination',
                  subtitle: 'Schedule and completed vaccines',
                  icon: Icons.vaccines_rounded,
                  color: ModuleColors.vaccination,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => VaccinationScreen(
                            babyId: babyId, babyName: babyName)),
                  ),
                ),
                HealthMenuTile(
                  title: 'Milestones',
                  subtitle: 'First smile, first steps and more',
                  icon: Icons.star_rounded,
                  color: ModuleColors.milestone,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MilestoneScreen(
                            babyId: babyId, babyName: babyName)),
                  ),
                ),
                HealthMenuTile(
                  title: 'Allergies',
                  subtitle: 'Known allergies and reactions',
                  icon: Icons.warning_amber_rounded,
                  color: ModuleColors.allergy,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AllergyScreen(babyId: babyId, babyName: babyName)),
                  ),
                ),
                HealthMenuTile(
                  title: 'Medical History',
                  subtitle: 'Illnesses, treatment and notes',
                  icon: Icons.medical_information_rounded,
                  color: ModuleColors.medical,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BabyMedicalHistoryScreen(
                            babyId: babyId, babyName: babyName)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
