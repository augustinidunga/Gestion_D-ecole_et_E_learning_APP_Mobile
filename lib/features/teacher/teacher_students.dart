import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

class TeacherStudents extends StatelessWidget {
  const TeacherStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.studentsOfTeacher(s.user!.id);
    if (list.isEmpty)
      return const EmptyState(Icons.groups_rounded, 'Aucun étudiant suivi.', 'Aucun étudiant n\'est affecté à cet enseignant.');
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        for (final st in list)
          AppCardElevated(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(st.initials),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        st.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        s.className(st.classId),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  s.averageOf(st.id) == null
                      ? '-'
                      : '${s.averageOf(st.id)!.toStringAsFixed(1)}/20',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent),
                ),
              ],
            ),
          ),
      ],
    );
  }
}