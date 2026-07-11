import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});
  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final _formKey = GlobalKey<FormState>();
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  bool isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirestoreService.add('blood_pressure', {
        'systolic': double.parse(systolicController.text.trim()),
        'diastolic': double.parse(diastolicController.text.trim()),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Blood pressure saved')));
      systolicController.clear();
      diastolicController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) =>
      FirestoreService.delete('blood_pressure', id);

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Pressure')),
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
                      title: 'Blood Pressure Tracker',
                      subtitle: 'Normal range: 120/80 mmHg',
                      color: ModuleColors.mother,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: systolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Systolic (Upper)', hintText: '120'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter systolic value';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: diastolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Diastolic (Lower)', hintText: '80'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter diastolic value';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Record',
                        color: ModuleColors.mother),
                    const SizedBox(height: 14),
                    Text('Full history is available in Records & Graphs',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12.5)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 320,
                      child: AppRecordStreamList(
                        collection: 'blood_pressure',
                        emptyMessage: 'No blood pressure records yet',
                        emptyIcon: Icons.monitor_heart_rounded,
                        itemBuilder: (context, data, id, pending) {
                          return AppRecordCard(
                            icon: Icons.monitor_heart_rounded,
                            color: ModuleColors.mother,
                            title:
                                'BP: ${data['systolic']}/${data['diastolic']}',
                            subtitle: 'mmHg',
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
