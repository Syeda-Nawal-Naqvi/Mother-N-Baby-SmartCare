import 'package:flutter/material.dart';
import '../../models/mother_profile_model.dart';
import '../../services/mother_profile_service.dart';
import '../../widgets/app_widgets.dart';
import 'blood_pressure_screen.dart';
import 'glucose_screen.dart';
import 'weight_screen.dart';
import 'medical_history_screen.dart';
import 'mother_profile_screen.dart';

class MotherHealthScreen extends StatelessWidget {
  const MotherHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mother Health Tracker')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: StreamBuilder<MotherProfileModel?>(
              stream: MotherProfileService().streamProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final profile = snapshot.data;

                // Profile setup is compulsory before any tracker can be used.
                if (profile == null) {
                  return _ProfileRequiredView();
                }

                return _TrackerMenu(profile: profile);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRequiredView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded,
                size: 56, color: ModuleColors.mother),
            const SizedBox(height: 14),
            const Text(
              'Set up the mother profile first',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Name, age, blood group and delivery dates are required '
              'before you can use blood pressure, glucose, weight or '
              'medical history tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ModuleColors.mother,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MotherProfileScreen()),
              ),
              child: const Text('Set Up Profile',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerMenu extends StatelessWidget {
  final MotherProfileModel profile;
  const _TrackerMenu({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ModuleHeaderCard(
          title: 'Mother Health Tracker',
          subtitle: 'Log blood pressure, glucose, weight and medical visits',
          icon: Icons.favorite_rounded,
          color: ModuleColors.mother,
        ),
        const SizedBox(height: 16),
        _ProfileSummaryCard(profile: profile),
        const SizedBox(height: 20),
        HealthMenuTile(
          title: 'Blood Pressure',
          subtitle: 'Track systolic / diastolic readings',
          icon: Icons.monitor_heart_rounded,
          color: ModuleColors.mother,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BloodPressureScreen())),
        ),
        HealthMenuTile(
          title: 'Glucose Level',
          subtitle: 'Track blood sugar readings',
          icon: Icons.bloodtype_rounded,
          color: ModuleColors.mother,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GlucoseScreen())),
        ),
        HealthMenuTile(
          title: 'Weight',
          subtitle: 'Track weekly weight',
          icon: Icons.scale_rounded,
          color: ModuleColors.mother,
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const WeightScreen())),
        ),
        HealthMenuTile(
          title: 'Medical History',
          subtitle: 'Doctor visits, medicines & notes',
          icon: Icons.medical_information_rounded,
          color: ModuleColors.mother,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MedicalHistoryScreen())),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final MotherProfileModel profile;
  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ModuleColors.mother.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(profile.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MotherProfileScreen(existingProfile: profile),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            Text('Age: ${profile.age}  •  Blood Group: ${profile.bloodGroup}',
                style: const TextStyle(color: Colors.grey)),
            if (profile.deliveries.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Deliveries:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: profile.deliveries
                    .map((d) => Chip(
                          label: Text('${d.label}: ${d.date}'),
                          backgroundColor: Colors.white,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
