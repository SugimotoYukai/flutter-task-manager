import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tansu_kanri/models/reminder.dart';
import 'package:tansu_kanri/providers/reminder_provider.dart';

class ReminderDetailScreen extends ConsumerStatefulWidget{
  const ReminderDetailScreen({super.key, required this.reminder});

  final Reminder reminder;

  @override
  ConsumerState<ReminderDetailScreen> createState() {
    return _ReminderDetailScreenState();
  }
}

class _ReminderDetailScreenState extends ConsumerState<ReminderDetailScreen>{
  final _user = FirebaseAuth.instance.currentUser!;
  var _do = false;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    if (widget.reminder.doMemberId.contains(_user.uid)) {
      _do = true;
    }
  }

  void _pickDate () async {
    final lastDate = DateTime.utc(2030, 12, 31);
    final date  = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now(), 
      lastDate: lastDate,
    );

    if (date == null) {
      return;
    }

    setState(() {
      _date = date;
      widget.reminder.deadline = Timestamp.fromDate(_date!);
    });
    
    ref.read(reminderProvider.notifier).deleteReminder(widget.reminder);
    ref.read(reminderProvider.notifier).addReminder(
      Reminder(
        id: widget.reminder.id, 
        groupId: widget.reminder.groupId, 
        title: widget.reminder.title, 
        colorname: widget.reminder.colorname, 
        createTime: widget.reminder.createTime, 
        creatorname: widget.reminder.creatorname, 
        creatorId: widget.reminder.creatorId,
        deadline: widget.reminder.deadline,
        doMember: widget.reminder.doMember,
        doMemberId: widget.reminder.doMemberId,
      ),
    );

    await FirebaseFirestore.instance.collection('Group').doc(widget.reminder.groupId).collection('Reminder').doc(widget.reminder.id).update(
      {
        'id' : widget.reminder.id,
        'color' : widget.reminder.colorname,
        'createTime' : widget.reminder.createTime,
        'creatorname' : widget.reminder.creatorname,
        'creatorId' : widget.reminder.creatorId,
        'title' : widget.reminder.title,
        'doMember' : widget.reminder.doMember,
        'doMemberId' : widget.reminder.doMemberId,
        'deadline' : _date,
      }
    );
  }

  void _addDomember () async {
    final preReminders = ref.read(reminderProvider);
    final preReminder = preReminders.firstWhere((rem) => rem.id == widget.reminder.id);
    
    final userData = await FirebaseFirestore.instance.collection('Users').doc(_user.uid).get();

      if (preReminder.doMemberId.contains(_user.uid)) {
        setState(() {
          _do = false;
          ref.read(reminderProvider.notifier).deleteReminder(widget.reminder);
          final index = widget.reminder.doMemberId.indexOf(_user.uid);
          widget.reminder.doMember.removeAt(index);
          widget.reminder.doMemberId.removeAt(index);
      ref.read(reminderProvider.notifier).addReminder(
        Reminder(
          id: widget.reminder.id, 
          groupId: widget.reminder.groupId, 
          title: widget.reminder.title, 
          colorname: widget.reminder.colorname, 
          createTime: widget.reminder.createTime, 
          creatorname: widget.reminder.creatorname, 
          creatorId: widget.reminder.creatorId,
          doMember: widget.reminder.doMember,
          doMemberId: widget.reminder.doMemberId,
          deadline: widget.reminder.deadline,
        ),
      );
        });
      await FirebaseFirestore.instance.collection('Group').doc(widget.reminder.groupId).collection('Reminder').doc(widget.reminder.id).update(
        {
          'id' : widget.reminder.id,
          'title' : widget.reminder.title,
          'creatorname' : widget.reminder.creatorname,
          'creatorId' : widget.reminder.creatorId,
          'createTime' : widget.reminder.createTime,
          'color' : widget.reminder.colorname,
          'deadline' : widget.reminder.deadline,
          'doMember' : widget.reminder.doMember,
          'doMemberId' : widget.reminder.doMemberId,
        }
      );
    } else {
      setState(() {
        _do = true;
        ref.read(reminderProvider.notifier).deleteReminder(widget.reminder);
        widget.reminder.doMember.add(userData.data()!['username']);
        widget.reminder.doMemberId.add(_user.uid);
      ref.read(reminderProvider.notifier).addReminder(
        Reminder(
          id: widget.reminder.id, 
          groupId: widget.reminder.groupId, 
          title: widget.reminder.title, 
          colorname: widget.reminder.colorname, 
          createTime: widget.reminder.createTime, 
          creatorname: widget.reminder.creatorname, 
          creatorId: widget.reminder.creatorId,
          doMember: widget.reminder.doMember,
          doMemberId: widget.reminder.doMemberId,
          deadline: widget.reminder.deadline,
        ),
      );
      });
      await FirebaseFirestore.instance.collection('Group').doc(widget.reminder.groupId).collection('Reminder').doc(widget.reminder.id).update(
        {
          'id' : widget.reminder.id,
          'title' : widget.reminder.title,
          'creatorname' : widget.reminder.creatorname,
          'creatorId' : widget.reminder.creatorId,
          'createTime' : widget.reminder.createTime,
          'color' : widget.reminder.colorname,
          'deadline' : widget.reminder.deadline,
          'doMember' : widget.reminder.doMember,
          'doMemberId' : widget.reminder.doMemberId
        }
      );
    }

    
  }

  @override
  Widget build(BuildContext context) {
    String formatDate = '';
    var formatter = DateFormat.yMd();

    if (widget.reminder.deadline != null) {
      String formatingDate () {
        return formatter.format(widget.reminder.deadline!.toDate());
      }
      formatDate = formatingDate();
    }

    String formatCreateDate () {
      return formatter.format(widget.reminder.createTime.toDate());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.reminder.title),
        actions: [
          IconButton(
            onPressed: _addDomember, 
            icon: _do ? const Icon(Icons.front_hand) 
            : const Icon(Icons.front_hand_outlined)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 32,
            ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '作成者',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 119, 118, 118),
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Text(
                    widget.reminder.creatorname,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16,),
              Row(
                children: [
                  const Text(
                    '作成日',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 119, 118, 118),
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Text(
                    formatCreateDate(),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16,),
              Row(
                children: [
                  const Text(
                    '期限',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 119, 118, 118),
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Text(
                    widget.reminder.deadline == null
                    ? '未設定'
                    : formatDate,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _pickDate, 
                    icon: const Icon(Icons.calendar_month)
                  ),
                ],
              ),
              const SizedBox(height: 16,),
              Row(
                children: [
                  const Text(
                    'やります！',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 119, 118, 118),
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Column(
                    children: [
                    for (final domember in widget.reminder.doMember)
                  Column(
                    children: [Text(
                      domember,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16,)
                  ]
                  ),
                    ]
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}