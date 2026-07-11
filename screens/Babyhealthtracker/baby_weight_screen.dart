import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class BabyWeightScreen extends StatefulWidget {
  final String babyId;
  final String babyName;
  const BabyWeightScreen(
      {super.key, required this.babyId, required this.babyName});
  @override
  State<BabyWeightScreen> createState() => _BabyWeightScreenState();
}

class _BabyWeightScreenState extends State<BabyWeightScreen> {
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
      await FirestoreService.add('baby_weight', {
        'babyId': widget.babyId,
        'weight': double.parse(weightController.text.trim()),
        'date': selectedDate.toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Baby weight saved')));
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

  Future<void> _delete(String id) => FirestoreService.delete('baby_weight', id);

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.babyName} — Weight')),
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
                      controller: weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight_rounded,
                      color: ModuleColors.weight,
                      hint: 'e.g. 4.5',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter weight';
                        }
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null) return 'Enter a valid number';
                        if (parsed <= 0 || parsed > 60) {
                          return 'Enter a realistic weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppDateTile(
                        date: selectedDate,
                        onTap: _pickDate,
                        color: ModuleColors.weight),
                    const SizedBox(height: 18),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Weight',
                        color: ModuleColors.weight),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AppRecordStreamList(
                        collection: 'baby_weight',
                        babyId: widget.babyId,
                        orderByField: 'date',
                        emptyMessage:
                            'No weight records yet for ${widget.babyName}',
                        emptyIcon: Icons.monitor_weight_rounded,
                        itemBuilder: (context, data, id, pending) {
                          final date = DateTime.tryParse(
                                  data['date']?.toString() ?? '') ??
                              DateTime.now();
                          return AppRecordCard(
                            icon: Icons.monitor_weight_rounded,
                            color: ModuleColors.weight,
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
