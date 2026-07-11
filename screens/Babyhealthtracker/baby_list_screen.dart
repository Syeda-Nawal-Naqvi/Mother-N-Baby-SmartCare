import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';
import 'baby_profile_detail_screen.dart';

/// Entry point of the Baby Health Tracker. Lists every baby profile the
/// user has created as a colorful, tappable card. If no profile exists yet
/// the user is prompted — this screen enforces that at least one baby
/// profile must be created before any health records can be added, since
/// every record (weight, vaccination, milestone, allergy, medical history)
/// is tied to a specific `babyId`.
class BabyListScreen extends StatefulWidget {
  const BabyListScreen({super.key});
  @override
  State<BabyListScreen> createState() => _BabyListScreenState();
}

class _BabyListScreenState extends State<BabyListScreen> {
  void _openAddBabySheet({String? babyId, Map<String, dynamic>? initialData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBabySheet(babyId: babyId, initialData: initialData),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete baby profile?'),
        content: Text(
            'This removes $name\'s profile. Their weight, vaccination, milestone, allergy and medical history records are kept separately and are not deleted automatically.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              FirestoreService.delete('babies', id);
            },
            child: const Text('Delete',
                style: TextStyle(color: ModuleColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Profiles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBabySheet,
        backgroundColor: ModuleColors.profile,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Baby'),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.stream('babies'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppEmptyState(
                    message: 'Could not load baby profiles: ${snapshot.error}',
                    icon: Icons.error_outline_rounded,
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return _EmptyBabiesPrompt(onCreate: _openAddBabySheet);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final dob =
                        DateTime.tryParse(data['dob']?.toString() ?? '') ??
                            DateTime.now();
                    return BabyProfileCard(
                      name: data['name'] ?? '',
                      gender: data['gender'] ?? '',
                      bloodGroup: data['bloodGroup'] ?? '',
                      dob: dob,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BabyProfileDetailScreen(
                            babyId: doc.id,
                            babyName: (data['name'] ?? '').toString().isEmpty
                                ? 'Baby'
                                : data['name'],
                          ),
                        ),
                      ),
                      onEdit: () =>
                          _openAddBabySheet(babyId: doc.id, initialData: data),
                      onDelete: () =>
                          _confirmDelete(doc.id, data['name'] ?? 'this baby'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBabiesPrompt extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyBabiesPrompt({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                  color: ModuleColors.profile.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: const Icon(Icons.child_care_rounded,
                  size: 42, color: ModuleColors.profile),
            ),
            const SizedBox(height: 20),
            Text('Create a Baby Profile to Get Started',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'You need at least one baby profile before you can record weight, vaccinations, milestones, allergies or medical history.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),
            AppSubmitButton(
              isLoading: false,
              onPressed: onCreate,
              label: 'Create Baby Profile',
              color: ModuleColors.profile,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBabySheet extends StatefulWidget {
  /// When null, the sheet creates a new baby profile. When set, it edits
  /// the existing profile with this document id instead.
  final String? babyId;

  /// Existing field values to pre-fill when editing. Ignored when
  /// [babyId] is null.
  final Map<String, dynamic>? initialData;

  const _AddBabySheet({this.babyId, this.initialData});

  bool get isEditing => babyId != null;

  @override
  State<_AddBabySheet> createState() => _AddBabySheetState();
}

class _AddBabySheetState extends State<_AddBabySheet> {
  final _formKey = GlobalKey<FormState>();
  late final nameController = TextEditingController(
      text: (widget.initialData?['name'] ?? '').toString());
  late String gender = _validGender(widget.initialData?['gender'] as String?);
  late String bloodGroup =
      _validBloodGroup(widget.initialData?['bloodGroup'] as String?);

  static const genderOptions = ['Male', 'Female', 'Transgender'];
  static const bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  static String _validGender(String? value) {
    return genderOptions.contains(value) ? value! : 'Male';
  }

  static String _validBloodGroup(String? value) {
    return bloodGroupOptions.contains(value) ? value! : 'Unknown';
  }

  late DateTime selectedDOB =
      DateTime.tryParse(widget.initialData?['dob']?.toString() ?? '') ??
          DateTime.now();
  bool isLoading = false;

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDOB = picked);
  }

  Future<void> _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final data = {
      'name': nameController.text.trim(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'dob': selectedDOB.toIso8601String(),
    };
    try {
      if (widget.isEditing) {
        await FirestoreService.update('babies', widget.babyId!, data);
      } else {
        await FirestoreService.add('babies', data);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.isEditing
              ? 'Baby profile updated successfully'
              : 'Baby profile created successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                    widget.isEditing ? 'Edit Baby Profile' : 'New Baby Profile',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    widget.isEditing
                        ? 'Update this baby\'s details. Existing weight, vaccination, milestone, allergy and medical records are not affected.'
                        : 'This information is used to keep each baby\'s records separate.',
                    style: GoogleFonts.poppins(
                        fontSize: 12.5, color: Colors.grey.shade600)),
                const SizedBox(height: 18),
                AppSectionField(
                  controller: nameController,
                  label: 'Baby Name',
                  icon: Icons.badge_rounded,
                  color: ModuleColors.profile,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter baby name'
                      : null,
                ),
                const SizedBox(height: 12),
                AppSectionDropdown(
                  label: 'Gender',
                  icon: Icons.wc_rounded,
                  color: ModuleColors.profile,
                  value: gender,
                  items: genderOptions,
                  onChanged: (v) => setState(() => gender = v ?? gender),
                ),
                const SizedBox(height: 12),
                AppDateTile(
                  date: selectedDOB,
                  onTap: _pickDOB,
                  label: 'Date of Birth',
                  color: ModuleColors.profile,
                ),
                const SizedBox(height: 12),
                AppSectionDropdown(
                  label: 'Blood Group',
                  icon: Icons.bloodtype_rounded,
                  color: ModuleColors.profile,
                  value: bloodGroup,
                  items: bloodGroupOptions,
                  onChanged: (v) =>
                      setState(() => bloodGroup = v ?? bloodGroup),
                ),
                const SizedBox(height: 20),
                AppSubmitButton(
                  isLoading: isLoading,
                  onPressed: _saveBaby,
                  label: widget.isEditing
                      ? 'Update Baby Profile'
                      : 'Save Baby Profile',
                  color: ModuleColors.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
