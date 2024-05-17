import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/models/reminder.dart';
import 'package:tansu_kanri/providers/reminder_provider.dart';
import 'package:uuid/uuid.dart';

class AddReminder extends ConsumerStatefulWidget {
  const AddReminder({
    super.key,
    required this.group,
    });

    final Group group;

  @override
  ConsumerState<AddReminder> createState() {
    return _AddReminderState();
  }
}

class _AddReminderState extends ConsumerState<AddReminder> {
  final _titleController = TextEditingController();
  final _colorname = 'black';
  Timestamp? deadline;
  var isLoading = false;

  void _saveReminder () async {
    setState(() {
      isLoading = true;
    });

    if (_titleController.text.trim().isEmpty) {
    setState(() {
      isLoading = false;
    });
      return;
    }

    final id = const Uuid().v4();
    final time = Timestamp.now();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

    ref.read(reminderProvider.notifier).addReminder(
      Reminder(
        id: id,
        groupId: widget.group.id,
        title: _titleController.text, 
        colorname: _colorname, 
        createTime: time, 
        creatorname: userData.data()!['username'], 
        creatorId: user.uid,
        deadline: deadline,
      )
    );

    await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).collection('Reminder').doc(id).set(
      {
        'title' : _titleController.text,
        'id' : id,
        'color' : _colorname,
        'createTime' : time,
        'creatorname' : userData.data()!['username'],
        'creatorId' : user.uid,
        'deadline' : deadline,
        'doMember' : [],
        'doMemberId' : [],
      }
    );

    setState(() {
      isLoading = false;
    });

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();

  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'タスクを追加',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                ),
              const SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'タイトルを入力'
                  ),
                  controller: _titleController,
                ),
              ),
              const SizedBox(height: 16,),
              Row(
                children: [
                  const SizedBox(width: 8,),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveReminder,
                    child: const Text('確定'),
                  ),
                ],
              ),
              const SizedBox(height: 400,)
            ],
          ),
        ),
      )
    ;
  }
}