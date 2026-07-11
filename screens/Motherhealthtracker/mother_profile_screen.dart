import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mother_and_baby_smartcare/models/mother_profile_model.dart';
import 'package:mother_and_baby_smartcare/services/mother_profile_service.dart';
import 'package:mother_and_baby_smartcare/widgets/app_widgets.dart';

class MotherProfileScreen extends StatefulWidget {
  final MotherProfileModel? existingProfile;
  const MotherProfileScreen({super.key, this.existingProfile});

  @override
  State<MotherProfileScreen> createState() => _MotherProfileScreenState();
}

class _MotherProfileScreenState extends State<MotherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final MotherProfileService _service = MotherProfileService();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _bloodGroup = 'A+';
  List<DeliveryRecord> _deliveries = [];
  bool _saving = false;

  bool get _isEditing => widget.existingProfile != null;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    if (p != null) {
      _nameController.text = p.name;
      _ageController.text = p.age.toString();
      _bloodGroup = p.bloodGroup.isNotEmpty ? p.bloodGroup : 'A+';
      _deliveries = p.deliveries
          .map((d) => DeliveryRecord(label: d.label, date: d.date))
          .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addDelivery() {
    setState(() {
      _deliveries.add(
        DeliveryRecord(label: 'Baby ${_deliveries.length + 1}', date: ''),
      );
    });
  }

  void _removeDelivery(int index) {
    setState(() => _deliveries.removeAt(index));
  }

  Future<void> _pickDeliveryDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _deliveries[index].date = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final missingDate = _deliveries.any((d) => d.date.isEmpty);
    if (missingDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please pick a date for every delivery entry.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final profile = MotherProfileModel(
        id: _isEditing ? widget.existingProfile!.id : null,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        bloodGroup: _bloodGroup,
        deliveries: _deliveries,
      );

      await _service.saveProfile(profile);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEditing ? 'Update Mother Profile' : 'Mother Profile Setup'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isEditing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Please complete this profile before using the health trackers.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Mother Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Age is required';
                final age = int.tryParse(v.trim());
                if (age == null || age <= 0 || age > 100) {
                  return 'Enter a valid age';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _bloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                border: OutlineInputBorder(),
              ),
              items: _bloodGroups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodGroup = v ?? _bloodGroup),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Dates',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addDelivery,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Baby'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_deliveries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No delivery dates added yet. Tap "Add Baby" if applicable.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            for (int i = 0; i < _deliveries.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _deliveries[i].label,
                          decoration: const InputDecoration(
                            labelText: 'Label',
                            isDense: true,
                          ),
                          onChanged: (v) => _deliveries[i].label = v,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () => _pickDeliveryDate(i),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Delivery Date',
                              isDense: true,
                            ),
                            child: Text(
                              _deliveries[i].date.isEmpty
                                  ? 'Tap to pick date'
                                  : _deliveries[i].date,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red),
                        onPressed: () => _removeDelivery(i),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModuleColors.mother,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEditing ? 'Update Profile' : 'Save Profile',
                        style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
