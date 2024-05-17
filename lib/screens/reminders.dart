import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/models/reminder.dart';
import 'package:tansu_kanri/providers/reminder_provider.dart';
import 'package:tansu_kanri/screens/add_reminder.dart';
import 'package:tansu_kanri/screens/group_setting.dart';
import 'package:tansu_kanri/screens/user_invite.dart';
import 'package:tansu_kanri/widgets/reminders_list.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  var isLoading = false;

  void _showOverlay () {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (ctx) =>  AddReminder(
      group: widget.group,
    ));
  }

  void _getReminder () async {
    setState(() {
      isLoading = true;
    });
    final remindersData = await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).collection('Reminder').get();
    final reminders = remindersData.docs;
    setState(() {
      isLoading = false;
    });
    for (final reminder in reminders) {
      ref.watch(reminderProvider.notifier).scanReminder(
        Reminder(
          id: reminder['id'], 
          groupId: widget.group.id,
          title: reminder['title'], 
          colorname: reminder['color'], 
          createTime: reminder['createTime'], 
          creatorname: reminder['creatorname'], 
          creatorId: reminder['creatorId'],
          deadline: reminder['deadline'],
          doMember: reminder['doMember'],
          doMemberId: reminder['doMemberId'],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getReminder();
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(reminderProvider);
    final jreminders = reminders.where((reminder) => reminder.groupId == widget.group.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupname),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => UserInviteScreen(group: widget.group))
              );
            }, 
            icon: const Icon(Icons.people)
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => GroupSettingScreen(group: widget.group))
              );
            }, 
            icon: const Icon(Icons.settings)
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOverlay,
        child: const Icon(Icons.add),
      ),
      body: isLoading 
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : ReminderList(
        reminders: jreminders,
        group: widget.group
      ),
    );
  }
}