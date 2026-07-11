import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});
  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final diseaseController = TextEditingController();
  final medicineController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirestoreService.add('medical_history', {
        'diseaseName': diseaseController.text.trim(),
        'medicines': medicineController.text.trim(),
        'doctorNotes': notesController.text.trim(),
        'visitDate': selectedDate.toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Medical history saved')));
      diseaseController.clear();
      medicineController.clear();
      notesController.clear();
      setState(() => selectedDate = DateTime.now());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) =>
      FirestoreService.delete('medical_history', id);

  @override
  void dispose() {
    diseaseController.dispose();
    medicineController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical History')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const InfoBanner(
                      title: 'Medical Record',
                      subtitle:
                          "Store disease history, medicines and doctor's notes",
                      color: ModuleColors.mother,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: diseaseController,
                      decoration:
                          const InputDecoration(labelText: 'Disease Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter disease name'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: medicineController,
                      decoration: const InputDecoration(labelText: 'Medicines'),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: notesController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(labelText: 'Doctor Notes'),
                    ),
                    const SizedBox(height: 16),
                    AppDateTile(
                        date: selectedDate,
                        onTap: _pickDate,
                        label: 'Visit Date'),
                    const SizedBox(height: 25),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Record',
                        color: ModuleColors.mother),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 320,
                      child: AppRecordStreamList(
                        collection: 'medical_history',
                        emptyMessage: 'No medical history yet',
                        emptyIcon: Icons.medical_information_rounded,
                        orderByField: 'visitDate',
                        itemBuilder: (context, data, id, pending) {
                          final visit = DateTime.tryParse(
                              data['visitDate']?.toString() ?? '');
                          return AppRecordCard(
                            icon: Icons.medical_information_rounded,
                            color: ModuleColors.mother,
                            title: data['diseaseName'] ?? '',
                            subtitle:
                                'Medicines: ${data['medicines'] ?? '-'}\nVisit: ${visit != null ? DateFormat('dd MMM yyyy').format(visit) : '-'}',
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
