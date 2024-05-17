import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/providers/group_provider.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() {
    return _JoinScreenState();
  }
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
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

    try {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    final groupData = await FirebaseFirestore.instance.collection('Group').doc(_titlecontroller.text).get();

    if (groupData.data() == null) {
      return;
    }
    final groupname = groupData.data()!['groupname'];
    final member = groupData.data()!['member'];
    final memberId = groupData.data()!['memberId'];
    final time = groupData.data()!['time'];


    ref.read(groupProvider.notifier).renewalGroup(Group(
      groupname: groupname, 
      id: _titlecontroller.text, 
      member: [
        ...member,
        userData.data()!['username']
      ], memberId: [
        ...memberId,
        userData.data()!['memberId']
      ], time: time));

    await FirebaseFirestore.instance.collection('Group').doc(_titlecontroller.text).update(
      {
        'groupname' : groupData['groupname'],
        'id' : groupData['id'],
        'member' : [
          ...groupData['member'],
          userData.data()!['username'],
        ],
        'memberId' : [
          ...groupData['memberId'],
          user.uid,
        ],
        'time' : groupData['time']
      }
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
        title: const Text('グループに参加する'),
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
                hintText: 'グループIDを入力してください'
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