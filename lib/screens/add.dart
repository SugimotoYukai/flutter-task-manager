import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/providers/group_provider.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({
    super.key});

  @override
  ConsumerState<AddScreen> createState() {
    return _AddScreenState();
  }
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final _titleController = TextEditingController();
  var isLoading = false;

  void _submit () async {
    if (_titleController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (_titleController.text.trim().length > 20) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('20文字以内にしてください'))
      );
      return;
    }

    final id = const Uuid().v4();
    final time = Timestamp.now();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    final userName = userData.data()!['username'];
    final userId = userData.data()!['id'];

    ref.read(groupProvider.notifier).addGroup(
      Group(groupname: _titleController.text, 
      id: id, 
      member: [userName.toString()], 
      memberId: [userId.toString()], 
      time: time
      )
    );

    await FirebaseFirestore.instance.collection('Group').doc(id).set(
      {
        'groupname' : _titleController.text,
        'time' : time,
        'id' : id,
        'member' : [
          userName.toString(),
        ],
        'memberId' : [
          userId.toString(),
        ]
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('グループを作成'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50,
            right: 20,
            left: 20,
          ),
          child: Column(
            children: [
              const Text('グループ名を入力してください'),
              const SizedBox(height: 16,),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '1～20文字',
                ),
              ),
              const SizedBox(height: 16,),
              ElevatedButton(
                onPressed: isLoading ? null :() {
                  _submit();
                }, 
                child: const Text('確定'),
              ),
            ],
          ),
        ),
      )
    );
  }
}