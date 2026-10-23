import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppUser? _peer;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<AppUser> _contacts(AppState s, AppUser u) {
    if (u.role == Role.student) {
      return s.teachers + s.users.where((x) => x.role == Role.admin).toList();
    }
    if (u.role == Role.teacher) {
      return s.students.where((st) => s.courses.any((c) => c.teacherId == u.id && c.classId == st.classId)).toList()
        ..addAll(s.users.where((x) => x.role == Role.admin));
    }
    return s.users.where((x) => x.id != u.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final contacts = _contacts(s, u);
    if (_peer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messagerie')),
        body: contacts.isEmpty
            ? const EmptyState(Icons.chat_bubble_outline, 'Aucun contact')
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: contacts.length,
                itemBuilder: (ctx, i) {
                  final c = contacts[i];
                  final conv = s.conversation(u.id, c.id);
                  final last = conv.isEmpty ? null : conv.last;
                  return AppCardElevated(
                    onTap: () => setState(() => _peer = c),
                    child: Row(children: [
                      CircleAvatar(backgroundColor: AppColors.primary, child: Text(c.initials, style: const TextStyle(color: Colors.white))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(last?.text ?? 'Aucun message', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Neumo.of(context).textMuted)),
                      ])),
                      if (s.unreadMessages(u.id) > 0)
                        StatusChip('${s.unreadMessages(u.id)}', AppColors.danger),
                    ]),
                  );
                },
              ),
      );
    }
    final peer = _peer!;
    final conv = s.conversation(u.id, peer.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(peer.name),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _peer = null)),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: conv.length,
            itemBuilder: (ctx, i) {
              final m = conv[i];
              final mine = m.senderId == u.id;
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: mine ? AppColors.primary : Neumo.of(context).surface,
                    borderRadius: BorderRadius.circular(16),
                    border: mine ? null : Border.all(color: AppColors.border),
                  ),
                  child: Text(m.text, style: TextStyle(color: mine ? Colors.white : Neumo.of(context).text)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Message...'))),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: () {
                s.sendMessage(_ctrl.text, receiverId: peer.id);
                _ctrl.clear();
              },
            ),
          ]),
        ),
      ]),
    );
  }
}
