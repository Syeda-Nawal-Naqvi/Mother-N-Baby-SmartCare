import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

class MilestoneScreen extends StatefulWidget {
  final String babyId;
  final String babyName;
  const MilestoneScreen(
      {super.key, required this.babyId, required this.babyName});
  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final milestoneController = TextEditingController();
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
      await FirestoreService.add('milestones', {
        'babyId': widget.babyId,
        'title': milestoneController.text.trim(),
        'milestoneDate': selectedDate.toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Milestone saved')));
      milestoneController.clear();
      setState(() => selectedDate = DateTime.now());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _delete(String id) => FirestoreService.delete('milestones', id);

  @override
  void dispose() {
    milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.babyName} — Milestones')),
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
                      controller: milestoneController,
                      label: 'Milestone (e.g. First Smile)',
                      icon: Icons.star_rounded,
                      color: ModuleColors.milestone,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter milestone'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppDateTile(
                        date: selectedDate,
                        onTap: _pickDate,
                        color: ModuleColors.milestone),
                    const SizedBox(height: 18),
                    AppSubmitButton(
                        isLoading: isLoading,
                        onPressed: _save,
                        label: 'Save Milestone',
                        color: ModuleColors.milestone),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AppRecordStreamList(
                        collection: 'milestones',
                        babyId: widget.babyId,
                        orderByField: 'milestoneDate',
                        emptyMessage:
                            'No milestones found for ${widget.babyName}',
                        emptyIcon: Icons.star_rounded,
                        itemBuilder: (context, data, id, pending) {
                          final date = DateTime.tryParse(
                              data['milestoneDate']?.toString() ?? '');
                          return AppRecordCard(
                            icon: Icons.star_rounded,
                            color: ModuleColors.milestone,
                            title: data['title'] ?? '',
                            subtitle: date != null
                                ? 'Date: ${DateFormat('dd MMM yyyy').format(date)}'
                                : '',
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
