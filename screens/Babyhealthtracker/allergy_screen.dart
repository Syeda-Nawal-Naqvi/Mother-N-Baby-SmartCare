import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class AllergyScreen extends StatefulWidget {
  final String babyId;
  final String babyName;
  const AllergyScreen(
      {super.key, required this.babyId, required this.babyName});
  @override
  State<AllergyScreen> createState() => _AllergyScreenState();
}

class _AllergyScreenState extends State<AllergyScreen> {
  final _formKey = GlobalKey<FormState>();
  final allergyController = TextEditingController();
  final reactionController = TextEditingController();
  final adviceController = TextEditingController();
  bool isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirestoreService.add('allergies', {
        'babyId': widget.babyId,
        'allergyName': allergyController.text.trim(),
        'reaction': reactionController.text.trim(),
        'advice': adviceController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Allergy saved')));
      allergyController.clear();
      reactionController.clear();
      adviceController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) => FirestoreService.delete('allergies', id);

  @override
  void dispose() {
    allergyController.dispose();
    reactionController.dispose();
    adviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.babyName} — Allergies')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppSectionField(
                      controller: allergyController,
                      label: 'Allergy Name',
                      icon: Icons.warning_amber_rounded,
                      color: ModuleColors.allergy,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter allergy name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppSectionField(
                      controller: reactionController,
                      label: 'Reaction',
                      icon: Icons.report_problem_rounded,
                      color: ModuleColors.allergy,
                    ),
                    const SizedBox(height: 12),
                    AppSectionField(
                      controller: adviceController,
                      label: 'Doctor Advice',
                      icon: Icons.medical_services_rounded,
                      color: ModuleColors.allergy,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Allergy',
                        color: ModuleColors.allergy),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AppRecordStreamList(
                        collection: 'allergies',
                        babyId: widget.babyId,
                        emptyMessage:
                            'No allergy records for ${widget.babyName}',
                        emptyIcon: Icons.warning_amber_rounded,
                        itemBuilder: (context, data, id, pending) {
                          return AppRecordCard(
                            icon: Icons.warning_amber_rounded,
                            color: ModuleColors.allergy,
                            title: data['allergyName'] ?? '',
                            subtitle:
                                'Reaction: ${data['reaction'] ?? '-'}\nAdvice: ${data['advice'] ?? '-'}',
                            onDelete: () => _delete(id),
                            pendingSync: pending,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
