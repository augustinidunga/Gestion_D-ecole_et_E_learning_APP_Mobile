import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _day = DateTime.now().weekday > 6 ? 1 : DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final classIds = u.role == Role.student
        ? [u.classId]
        : s.courses
            .where((c) => c.teacherId == u.id)
            .map((c) => c.classId)
            .toSet()
            .toList();
    final slots = [for (final c in classIds) ...s.slotsFor(c, _day)]
      ..sort((a, b) => a.start.compareTo(b.start));
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Emploi du temps'),
      ),
      body: Column(
        children: [
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var d = 1; d <= 6; d++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(weekdays[d]),
                      selected: _day == d,
                      onSelected: (_) => setState(() => _day = d),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: slots.isEmpty
                ? const EmptyState(
                    Icons.event_available_rounded,
                    'Aucun cours ce jour-là',
                    'Consultez un autre jour pour voir vos créneaux.')
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      for (final sl in slots)
                        AppCardElevated(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    sl.start,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary),
                                  ),
                                  Text(
                                    sl.end,
                                    style: const TextStyle(
                                        color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 3,
                                height: 44,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sl.subject,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '${sl.room} • ${u.role == Role.student ? sl.teacher : s.className(sl.classId)}',
                                      style: const TextStyle(
                                          color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
