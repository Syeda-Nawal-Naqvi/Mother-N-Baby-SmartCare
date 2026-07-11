import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class VaccinationScreen extends StatefulWidget {
  final String babyId;
  final String babyName;
  const VaccinationScreen(
      {super.key, required this.babyId, required this.babyName});
  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final vaccineController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String status = 'Pending';
  bool isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirestoreService.add('vaccinations', {
        'babyId': widget.babyId,
        'vaccineName': vaccineController.text.trim(),
        'vaccinationDate': selectedDate.toIso8601String(),
        'status': status,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vaccination saved')));
      vaccineController.clear();
      setState(() {
        selectedDate = DateTime.now();
        status = 'Pending';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) =>
      FirestoreService.delete('vaccinations', id);

  @override
  void dispose() {
    vaccineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.babyName} — Vaccination')),
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
                      controller: vaccineController,
                      label: 'Vaccine Name',
                      icon: Icons.vaccines_rounded,
                      color: ModuleColors.vaccination,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter vaccine name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppDateTile(
                        date: selectedDate,
                        onTap: _pickDate,
                        label: 'Vaccination Date',
                        color: ModuleColors.vaccination),
                    const SizedBox(height: 12),
                    AppSectionDropdown(
                      label: 'Status',
                      icon: Icons.fact_check_rounded,
                      color: ModuleColors.vaccination,
                      value: status,
                      items: const ['Pending', 'Completed'],
                      onChanged: (v) => setState(() => status = v ?? status),
                    ),
                    const SizedBox(height: 18),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Vaccination',
                        color: ModuleColors.vaccination),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AppRecordStreamList(
                        collection: 'vaccinations',
                        babyId: widget.babyId,
                        orderByField: 'vaccinationDate',
                        emptyMessage:
                            'No vaccination records for ${widget.babyName}',
                        emptyIcon: Icons.vaccines_rounded,
                        itemBuilder: (context, data, id, pending) {
                          final vDate = DateTime.tryParse(
                              data['vaccinationDate']?.toString() ?? '');
                          return AppRecordCard(
                            icon: Icons.vaccines_rounded,
                            color: ModuleColors.vaccination,
                            title: data['vaccineName'] ?? '',
                            subtitle:
                                'Date: ${vDate != null ? DateFormat('dd MMM yyyy').format(vDate) : '-'}\nStatus: ${data['status'] ?? '-'}',
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
