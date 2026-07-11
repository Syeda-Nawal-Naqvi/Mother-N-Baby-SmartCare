import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class GlucoseScreen extends StatefulWidget {
  const GlucoseScreen({super.key});
  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final glucoseController = TextEditingController();
  bool isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirestoreService.add('glucose_records', {
        'glucose': double.parse(glucoseController.text.trim()),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Glucose record saved')));
      glucoseController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) =>
      FirestoreService.delete('glucose_records', id);

  @override
  void dispose() {
    glucoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Glucose Level')),
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
                      title: 'Glucose Information',
                      subtitle: 'Normal fasting range: 70 – 99 mg/dL',
                      color: ModuleColors.mother,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: glucoseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Glucose Level (mg/dL)', hintText: '95'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter glucose level';
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
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 320,
                      child: AppRecordStreamList(
                        collection: 'glucose_records',
                        emptyMessage: 'No glucose records yet',
                        emptyIcon: Icons.bloodtype_rounded,
                        itemBuilder: (context, data, id, pending) {
                          return AppRecordCard(
                            icon: Icons.bloodtype_rounded,
                            color: ModuleColors.mother,
                            title: '${data['glucose']} mg/dL',
                            subtitle: 'Glucose reading',
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
