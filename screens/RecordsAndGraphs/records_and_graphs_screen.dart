import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/firebase_service.dart';
import '../../widgets/app_widgets.dart';

/// Landing screen for Records & Graphs. The user first chooses whose
/// records they want to see — Mother, or a specific Baby — since the two
/// datasets are entirely separate.
class RecordsGraphsScreen extends StatelessWidget {
  const RecordsGraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records & Graphs')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Whose records would you like to view?',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                AppChoiceCard(
                  title: 'Mother Records',
                  subtitle: 'Weight, blood pressure and glucose trends',
                  icon: Icons.pregnant_woman_rounded,
                  color: ModuleColors.mother,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _MotherRecordsGraphsScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                AppChoiceCard(
                  title: 'Baby Records',
                  subtitle: 'Pick a baby profile to view their records',
                  icon: Icons.child_care_rounded,
                  color: ModuleColors.baby,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _BabyProfilePickerScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

// ---------------------------------------------------------------------
// Mother records & graphs (unchanged data, own screen now)
// ---------------------------------------------------------------------

class _MotherRecordsGraphsScreen extends StatelessWidget {
  const _MotherRecordsGraphsScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mother Records & Graphs'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Records'), Tab(text: 'Graphs')],
          ),
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: const [
                      _SectionTitle('👩 Mother Records', ModuleColors.mother),
                      _RecordList('mother_weight', 'Weight', 'weight', 'kg',
                          Icons.scale_rounded),
                      _BpRecordList(),
                      _RecordList('glucose_records', 'Glucose', 'glucose',
                          'mg/dL', Icons.bloodtype_rounded),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: const [
                      _SectionTitle(
                          '📊 Mother Weight Trend', ModuleColors.mother),
                      _TrendChart(
                          collection: 'mother_weight',
                          field: 'weight',
                          color: ModuleColors.mother),
                      SizedBox(height: 20),
                      _SectionTitle('📊 Glucose Trend', ModuleColors.mother),
                      _TrendChart(
                          collection: 'glucose_records',
                          field: 'glucose',
                          color: ModuleColors.mother),
                      SizedBox(height: 20),
                      _SectionTitle('📊 Blood Pressure Trend (Systolic)',
                          ModuleColors.records),
                      _TrendChart(
                          collection: 'blood_pressure',
                          field: 'systolic',
                          color: ModuleColors.records),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Baby profile picker -> per-baby records & graphs
// ---------------------------------------------------------------------

class _BabyProfilePickerScreen extends StatelessWidget {
  const _BabyProfilePickerScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Baby')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.stream('babies'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const AppEmptyState(
                    message:
                        'No baby profiles yet.\nCreate one from the Baby Health Tracker first.',
                    icon: Icons.child_care_rounded,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final dob =
                        DateTime.tryParse(data['dob']?.toString() ?? '') ??
                            DateTime.now();
                    return BabyProfileCard(
                      name: data['name'] ?? '',
                      gender: data['gender'] ?? '',
                      bloodGroup: data['bloodGroup'] ?? '',
                      dob: dob,
                      color: ModuleColors.baby,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _BabyRecordsGraphsScreen(
                            babyId: doc.id,
                            babyName: (data['name'] ?? '').toString().isEmpty
                                ? 'Baby'
                                : data['name'],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BabyRecordsGraphsScreen extends StatelessWidget {
  final String babyId;
  final String babyName;
  const _BabyRecordsGraphsScreen(
      {required this.babyId, required this.babyName});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$babyName — Records & Graphs'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Records'), Tab(text: 'Graphs')],
          ),
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _SectionTitle(
                          '👶 $babyName\'s Records', ModuleColors.baby),
                      _RecordList('baby_weight', 'Weight', 'weight', 'kg',
                          Icons.monitor_weight_rounded,
                          babyId: babyId, color: ModuleColors.weight),
                      _RecordList('vaccinations', 'Vaccine', 'vaccineName', '',
                          Icons.vaccines_rounded,
                          babyId: babyId, color: ModuleColors.vaccination),
                      _RecordList('allergies', 'Allergy', 'allergyName', '',
                          Icons.warning_amber_rounded,
                          babyId: babyId, color: ModuleColors.allergy),
                      _RecordList('milestones', 'Milestone', 'title', '',
                          Icons.star_rounded,
                          babyId: babyId, color: ModuleColors.milestone),
                      _RecordList('baby_medical_history', 'Medical', 'disease',
                          '', Icons.healing_rounded,
                          babyId: babyId, color: ModuleColors.medical),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _SectionTitle(
                          '📊 $babyName\'s Weight Trend', ModuleColors.weight),
                      _TrendChart(
                          collection: 'baby_weight',
                          field: 'weight',
                          color: ModuleColors.weight,
                          babyId: babyId,
                          dateField: 'date'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared read-only list/chart building blocks
// ---------------------------------------------------------------------

/// A read-only, non-scrolling version of a collection's records, built on
/// top of the same offline-aware merge logic as [AppRecordStreamList] but
/// sized to fit inline inside the outer ListView instead of expanding.
/// Pass [babyId] to scope it to one baby's records.
class _RecordList extends StatelessWidget {
  final String collection;
  final String label;
  final String field;
  final String unit;
  final IconData icon;
  final String? babyId;
  final Color color;
  const _RecordList(
      this.collection, this.label, this.field, this.unit, this.icon,
      {this.babyId, this.color = ModuleColors.records});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: AppRecordStreamList(
        collection: collection,
        babyId: babyId,
        emptyMessage: 'No $label records yet',
        emptyIcon: icon,
        itemBuilder: (context, data, id, pending) {
          final createdAt =
              DateTime.tryParse(data['createdAt']?.toString() ?? '');
          return AppRecordCard(
            icon: icon,
            color: color,
            title: '$label: ${data[field] ?? ''} $unit'.trim(),
            subtitle: createdAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
                : '',
            onDelete: () => FirestoreService.delete(collection, id),
            pendingSync: pending,
          );
        },
      ),
    );
  }
}

class _BpRecordList extends StatelessWidget {
  const _BpRecordList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: AppRecordStreamList(
        collection: 'blood_pressure',
        emptyMessage: 'No blood pressure records yet',
        emptyIcon: Icons.monitor_heart_rounded,
        itemBuilder: (context, data, id, pending) {
          final createdAt =
              DateTime.tryParse(data['createdAt']?.toString() ?? '');
          return AppRecordCard(
            icon: Icons.monitor_heart_rounded,
            color: ModuleColors.records,
            title: 'BP: ${data['systolic']}/${data['diastolic']}',
            subtitle: createdAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
                : '',
            onDelete: () => FirestoreService.delete('blood_pressure', id),
            pendingSync: pending,
          );
        },
      ),
    );
  }
}

/// Line chart of a numeric field over time. Pass [babyId] to scope the
/// data to one baby (uses the babyId-filtered, client-sorted stream so no
/// composite Firestore index is required); otherwise streams the whole
/// collection ordered oldest-first by [dateField].
class _TrendChart extends StatelessWidget {
  final String collection;
  final String field;
  final Color color;
  final String? babyId;
  final String dateField;
  const _TrendChart({
    required this.collection,
    required this.field,
    required this.color,
    this.babyId,
    this.dateField = 'createdAt',
  });

  @override
  Widget build(BuildContext context) {
    final stream = babyId != null
        ? FirestoreService.streamByBaby(collection, babyId!)
        : FirestoreService.stream(collection, descending: false);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
              height: 220, child: Center(child: CircularProgressIndicator()));
        }
        var docs = snapshot.data!.docs;
        if (babyId != null) {
          docs = FirestoreService.sortByField(docs, dateField, false);
        }
        final values = <double>[];
        final labels = <String>[];
        for (final d in docs) {
          final data = d.data();
          if (data[field] == null) continue;
          values.add(double.tryParse(data[field].toString()) ?? 0);
          final when = data[dateField] ?? data['createdAt'];
          DateTime? dt;
          if (when is Timestamp) dt = when.toDate();
          if (when is String) dt = DateTime.tryParse(when);
          labels.add(dt != null ? DateFormat('d MMM').format(dt) : '');
        }
        if (values.isEmpty) {
          return const AppEmptyState(
              message: 'No data yet', icon: Icons.show_chart_rounded);
        }
        return Container(
          height: 240,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval:
                        (values.length / 4).clamp(1, values.length).toDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(labels[index],
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade600)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                      show: true, color: color.withValues(alpha: 0.12)),
                  spots: [
                    for (int i = 0; i < values.length; i++)
                      FlSpot(i.toDouble(), values[i]),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
