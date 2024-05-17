import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/providers/group_provider.dart';

class UserInviteScreen extends ConsumerStatefulWidget {
  const UserInviteScreen({
    super.key,
    required this.group,
    });

  final Group group;

  @override
  ConsumerState<UserInviteScreen> createState() {
    return _UserInviteScreenState();
  }
}

class _UserInviteScreenState extends ConsumerState<UserInviteScreen> {
  final _titlecontroller = TextEditingController();

  @override
  void dispose() {
    _titlecontroller.dispose();
    super.dispose();
  }

  void _joinGroup () async {

    if (_titlecontroller.text.trim().isEmpty) {
      return;
    }
    if (widget.group.memberId.contains(_titlecontroller.text)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
      content: Text('すでに参加しています'),
      )
      );
      return;
    }

    try {
    final userData = await FirebaseFirestore.instance.collection('Users').doc(_titlecontroller.text).get();

    await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).update(
      {
        'groupname' : widget.group.groupname,
        'id' : widget.group.id,
        'member' : [
          ...widget.group.member,
          userData.data()!['username'],
        ],
        'memberId' : [
          ...widget.group.memberId,
          _titlecontroller.text,
        ],
        'time' : widget.group.time
      }
    );
    ref.read(groupProvider.notifier).changeName(
      Group(
        groupname: widget.group.groupname, 
        id: widget.group.id, 
        member: [
          ...widget.group.member,
          userData.data()!['username'],
        ], 
        memberId: [
          ...widget.group.memberId,
          _titlecontroller.text,
        ], 
        time: widget.group.time)
    );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不明なエラー'),)
      );
    }

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザーを招待する'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          right: 16,
          left: 16,
        ),
        child: Column(
          children: [
            TextField(
              controller: _titlecontroller,
              decoration: const InputDecoration(
                hintText: 'ユーザーIDを入力してください'
              ),
            ),
            const SizedBox(height: 16,),
            ElevatedButton(
              onPressed: () {
                _joinGroup();
              }, 
              child: const Text('確定'),
            ),
          ],
        ),
      ),
    );
  }
}