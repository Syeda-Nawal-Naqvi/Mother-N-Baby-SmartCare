import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/firebase_service.dart';

/// Central color palette for the app. Each health module gets its own
/// distinct color so the UI reads as colorful and purposeful rather than
/// a single tint repeated everywhere.
class ModuleColors {
  static const mother = Color(0xFFE91E8C);
  static const motherLight = Color(0xFFFFE4F2);
  static const baby = Color(0xFF3B82F6);
  static const babyLight = Color(0xFFDBEAFE);
  static const records = Color(0xFF10B981);
  static const recordsLight = Color(0xFFD1FAE5);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF2A93B);

  // Per-module accents used inside the Baby Health Tracker so each section
  // (weight, vaccination, milestone, allergy, medical history) has its own
  // visual identity instead of everything being blue or pink.
  static const profile = Color(0xFFEC4899); // baby profile — magenta/pink
  static const weight = Color(0xFF3B82F6); // weight — blue
  static const vaccination = Color(0xFF8B5CF6); // vaccination — purple
  static const milestone = Color(0xFFF59E0B); // milestones — amber
  static const allergy = Color(0xFFEF4444); // allergies — red
  static const medical = Color(0xFF14B8A6); // medical history — teal
}

/// Shown across screens whenever the device is offline, so the user
/// understands why a record looks "unsynced" rather than assuming the app
/// is broken. Firestore keeps working (and queuing writes) underneath this
/// regardless — it's purely informational.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FirestoreService.isOnline,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: ModuleColors.warning.withValues(alpha: 0.15),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 18, color: ModuleColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "You're offline — changes are saved and will sync automatically once you're back online.",
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  const InfoBanner(
      {super.key,
      required this.title,
      this.subtitle = '',
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700, color: color)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey.shade600)),
            ],
          ],
        ),
      ),
    );
  }
}

class AppDateTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final String label;
  final Color color;
  const AppDateTile({
    super.key,
    required this.date,
    required this.onTap,
    this.label = 'Select Date',
    this.color = ModuleColors.baby,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_month_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(DateFormat('dd MMM yyyy').format(date),
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14.5)),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

/// A single form input rendered as a colorful rectangular box with an
/// icon, replacing plain [TextFormField]s across the app for a more
/// professional, sectioned look.
class AppSectionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const AppSectionField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: maxLines > 1 ? 14 : 10, bottom: maxLines > 1 ? 0 : 10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14.5),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                labelStyle: GoogleFonts.poppins(
                    fontSize: 12.5, color: Colors.grey.shade600),
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dropdown rendered inside the same colorful rectangular box style as
/// [AppSectionField], used for fields like Gender or Status.
class AppSectionDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const AppSectionDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600))))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                labelStyle: GoogleFonts.poppins(
                    fontSize: 12.5, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final Color color;
  const AppSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    this.color = ModuleColors.mother,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white))
            : Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
      ),
    );
  }
}

class AppRecordCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  /// True while this record hasn't been confirmed by the Firestore server
  /// yet (i.e. `doc.metadata.hasPendingWrites`). Shows a small sync icon
  /// instead of blocking the UI — the record is already safely queued.
  final bool pendingSync;

  const AppRecordCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    this.pendingSync = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
        isThreeLine: subtitle.contains('\n'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pendingSync)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: 'Waiting to sync',
                  child: Icon(Icons.sync_rounded,
                      size: 18, color: Colors.grey.shade500),
                ),
              ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: ModuleColors.danger),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Delete',
                style: TextStyle(color: ModuleColors.danger)),
          ),
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const AppEmptyState(
      {super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class ModuleHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const ModuleHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const HealthMenuTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A colorful, tappable card representing one baby profile — used in the
/// Baby Profiles list and the Records & Graphs baby picker.
class BabyProfileCard extends StatelessWidget {
  final String name;
  final String gender;
  final String bloodGroup;
  final DateTime dob;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const BabyProfileCard({
    super.key,
    required this.name,
    required this.gender,
    required this.bloodGroup,
    required this.dob,
    required this.onTap,
    this.color = ModuleColors.profile,
    this.onDelete,
    this.onEdit,
  });

  static String _ageString(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months -= 1;
    if (months < 1) {
      final days = now.difference(dob).inDays;
      return days <= 0 ? 'Newborn' : '$days day${days == 1 ? '' : 's'} old';
    }
    if (months < 24) return '$months month${months == 1 ? '' : 's'} old';
    final years = months ~/ 12;
    return '$years yr${years == 1 ? '' : 's'} old';
  }

  @override
  Widget build(BuildContext context) {
    final isGirl = gender.toLowerCase().startsWith('f');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Icon(isGirl ? Icons.girl_rounded : Icons.boy_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'Unnamed Baby' : name,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (gender.isNotEmpty) gender,
                          _ageString(dob),
                          if (bloodGroup.isNotEmpty) bloodGroup,
                        ].join(' • '),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.92)),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: onEdit,
                    tooltip: 'Edit profile',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: onDelete,
                    tooltip: 'Delete profile',
                  ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A large colorful choice card, used for top-level either/or navigation
/// such as "Mother Records" vs "Baby Records".
class AppChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AppChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: AppEmptyState(
          message: '$title is coming soon',
          icon: Icons.hourglass_empty_rounded,
        ),
      ),
    );
  }
}

/// Renders a Firestore-backed list, newest-first by default, with a
/// per-record "waiting to sync" indicator read straight off Firestore's own
/// `metadata.hasPendingWrites` — no separate local-storage layer required,
/// since offline persistence already keeps the stream populated while
/// offline.
///
/// Pass [babyId] to scope the list to a single baby's records. When
/// [babyId] is set, records are fetched with a simple equality filter (no
/// composite Firestore index required) and sorted by [orderByField] on the
/// client instead of in the query.
class AppRecordStreamList extends StatelessWidget {
  final String collection;
  final String? babyId;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool descending;
  final String orderByField;
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> data,
    String id,
    bool pendingSync,
  ) itemBuilder;

  const AppRecordStreamList({
    super.key,
    required this.collection,
    required this.itemBuilder,
    this.babyId,
    this.emptyMessage = 'No records yet',
    this.emptyIcon = Icons.inbox_outlined,
    this.descending = true,
    this.orderByField = 'createdAt',
  });

  @override
  Widget build(BuildContext context) {
    final stream = babyId != null
        ? FirestoreService.streamByBaby(collection, babyId!)
        : FirestoreService.stream(
            collection,
            orderBy: orderByField,
            descending: descending,
          );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            message: 'Could not load records: ${snapshot.error}',
            icon: Icons.error_outline_rounded,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snapshot.data!.docs.toList();
        if (docs.isEmpty) {
          return AppEmptyState(message: emptyMessage, icon: emptyIcon);
        }
        if (babyId != null) {
          docs = FirestoreService.sortByField(docs, orderByField, descending);
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = Map<String, dynamic>.from(doc.data());
            return itemBuilder(
              context,
              data,
              doc.id,
              doc.metadata.hasPendingWrites,
            );
          },
        );
      },
    );
  }
}
