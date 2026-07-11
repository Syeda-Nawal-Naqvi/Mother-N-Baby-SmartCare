import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});
  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
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
      await FirestoreService.add('mother_weight', {
        'weight': double.parse(weightController.text.trim()),
        'date': selectedDate.toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight saved successfully')));
      weightController.clear();
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
      FirestoreService.delete('mother_weight', id);

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight Tracker')),
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
                      title: 'Weight Tracking',
                      subtitle: 'Enter weight in kilograms — e.g. 55.5 kg',
                      color: ModuleColors.mother,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Weight (kg)', hintText: '55.5'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter weight';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppDateTile(
                        date: selectedDate,
                        onTap: _pickDate,
                        label: 'Record Date'),
                    const SizedBox(height: 25),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Weight',
                        color: ModuleColors.mother),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 320,
                      child: AppRecordStreamList(
                        collection: 'mother_weight',
                        emptyMessage: 'No weight records yet',
                        emptyIcon: Icons.scale_rounded,
                        itemBuilder: (context, data, id, pending) {
                          final date = DateTime.tryParse(
                                  data['date']?.toString() ?? '') ??
                              DateTime.now();
                          return AppRecordCard(
                            icon: Icons.scale_rounded,
                            color: ModuleColors.mother,
                            title: '${data['weight']} kg',
                            subtitle: DateFormat('dd MMM yyyy').format(date),
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
