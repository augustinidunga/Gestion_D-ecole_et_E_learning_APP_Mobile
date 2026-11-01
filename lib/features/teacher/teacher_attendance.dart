import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class TeacherAttendance extends StatefulWidget {
  const TeacherAttendance({super.key});
  @override
  State<TeacherAttendance> createState() => _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  DateTime _date = DateTime.now();
  SchoolClass? _class;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final classes = s.classes;
    _class ??= classes.isNotEmpty ? classes.first : null;
    final students = s.students.where((st) => st.classId == _class?.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('teacher.attendance.title'))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: AppDropdownFormField<SchoolClass>(
                value: _class,
                label: l10n.t('admin.classes.title'),
                icon: Icons.class_rounded,
                items: [for (final c in classes) DropdownMenuEntry(value: c, label: c.name)],
                onChanged: (v) => setState(() => _class = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppFormButton(
                text: fmtDate(_date),
                icon: Icons.calendar_today_rounded,
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2024), lastDate: DateTime(2027));
                  if (d != null) setState(() => _date = d);
                },
              ),
            ),
          ]),
        ),
        Expanded(
          child: students.isEmpty
              ? const EmptyState(Icons.groups_outlined, '', '')
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  itemBuilder: (ctx, i) {
                    final st = students[i];
                    final recs = s.attendanceForClass(_class!.id, _date);
                    final rec = recs.firstWhere((r) => r.studentId == st.id, orElse: () => AttendanceRecord('', _class!.id, st.id, _date, true));
                    final present = rec.id.isEmpty ? true : rec.present;
                    return AppCardElevated(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: present,
                        onChanged: (v) => s.markAttendance(_class!.id, st.id, _date, v),
                        title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(st.email, style: TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                        activeColor: AppColors.accent,
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
