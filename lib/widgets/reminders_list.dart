import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/models/reminder.dart';
import 'package:tansu_kanri/providers/reminder_provider.dart';
import 'package:tansu_kanri/screens/reminder_detail.dart';

class ReminderList extends ConsumerStatefulWidget {
  const ReminderList({
    super.key,
    required this.reminders,
    required this.group,
    });

  final List<Reminder> reminders;
  final Group group;

  @override
  ConsumerState<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends ConsumerState<ReminderList> {
  final _user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    void deleteReminder (int index) async {
      
      await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).collection('Reminder').doc(widget.reminders[index].id).delete();
      setState(() {
        ref.read(reminderProvider.notifier).deleteReminder(widget.reminders[index]);
      });
      
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).clearSnackBars();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('リマインダーを完了しました'),
      duration: Duration(seconds: 2),
      )
    );
  }

    if (widget.reminders.isEmpty) {
      return const Center(
        child: Text('タスクがありません'),
      );
    }

    return ListView.builder(
      itemCount: widget.reminders.length,
      itemBuilder: (ctx, index) {
        Widget? icon;

        if (widget.reminders[index].doMemberId.isNotEmpty) {
          icon = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.front_hand,
                color: widget.reminders[index].doMemberId.contains(_user.uid)
                ? Theme.of(context).colorScheme.primary
                : null,
              ),
              if (widget.reminders[index].doMember.length > 1)
              Text(
                widget.reminders[index].doMember.length.toString(),
                style: const TextStyle(
                  fontSize: 14
                ),
              ),
            ],
          );
        }

        return ListTile(
          leading: IconButton(
            onPressed: () {
              deleteReminder(index);
            }, 
            icon: const Icon(
              Icons.circle_outlined,
              size: 20,
              ),
            ),
          title: Text(
            widget.reminders[index].title,
            style: const TextStyle(
              fontSize: 20
            ),
          ),
          trailing: icon,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => ReminderDetailScreen(reminder: widget.reminders[index]))
            );
          },
        );
      },
    );
  }
}