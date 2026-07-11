import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class BabyMedicalHistoryScreen extends StatefulWidget {
  final String babyId;
  final String babyName;
  const BabyMedicalHistoryScreen(
      {super.key, required this.babyId, required this.babyName});
  @override
  State<BabyMedicalHistoryScreen> createState() =>
      _BabyMedicalHistoryScreenState();
}

class _BabyMedicalHistoryScreenState extends State<BabyMedicalHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final diseaseController = TextEditingController();
  final treatmentController = TextEditingController();
  final notesController = TextEditingController();
  bool isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirestoreService.add('baby_medical_history', {
        'babyId': widget.babyId,
        'disease': diseaseController.text.trim(),
        'treatment': treatmentController.text.trim(),
        'notes': notesController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Record saved')));
      diseaseController.clear();
      treatmentController.clear();
      notesController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) =>
      FirestoreService.delete('baby_medical_history', id);

  @override
  void dispose() {
    diseaseController.dispose();
    treatmentController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.babyName} — Medical History')),
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
                      controller: diseaseController,
                      label: 'Disease Name',
                      icon: Icons.healing_rounded,
                      color: ModuleColors.medical,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter disease name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppSectionField(
                      controller: treatmentController,
                      label: 'Treatment / Medicine',
                      icon: Icons.medication_rounded,
                      color: ModuleColors.medical,
                    ),
                    const SizedBox(height: 12),
                    AppSectionField(
                      controller: notesController,
                      label: 'Doctor Notes',
                      icon: Icons.note_alt_rounded,
                      color: ModuleColors.medical,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Record',
                        color: ModuleColors.medical),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AppRecordStreamList(
                        collection: 'baby_medical_history',
                        babyId: widget.babyId,
                        emptyMessage: 'No records found for ${widget.babyName}',
                        emptyIcon: Icons.healing_rounded,
                        itemBuilder: (context, data, id, pending) {
                          return AppRecordCard(
                            icon: Icons.healing_rounded,
                            color: ModuleColors.medical,
                            title: data['disease'] ?? '',
                            subtitle:
                                'Treatment: ${data['treatment'] ?? '-'}\nNotes: ${data['notes'] ?? '-'}',
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
