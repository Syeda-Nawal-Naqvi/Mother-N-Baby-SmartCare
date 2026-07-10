import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ModuleColors {
  static const mother = Color(0xFFE91E8C);
  static const motherLight = Color(0xFFFFE4F2);
  static const baby = Color(0xFF3B82F6);
  static const babyLight = Color(0xFFDBEAFE);
  static const records = Color(0xFF10B981);
  static const recordsLight = Color(0xFFD1FAE5);
  static const danger = Color(0xFFEF4444);
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
  const AppDateTile(
      {super.key,
      required this.date,
      required this.onTap,
      this.label = 'Select Date'});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200)),
      tileColor: Colors.white,
      leading: const Icon(Icons.calendar_month, color: Colors.grey),
      title: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
      subtitle: Text(DateFormat('dd MMM yyyy').format(date),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.edit, size: 18),
      onTap: onTap,
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
  const AppRecordCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onDelete,
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
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: ModuleColors.danger),
          onPressed: onDelete,
        ),
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
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
