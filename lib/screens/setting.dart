import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/models/group.dart';

import 'package:tansu_kanri/models/user.dart';
import 'package:tansu_kanri/providers/group_provider.dart';
import 'package:tansu_kanri/providers/user_provider.dart';
import 'package:tansu_kanri/widgets/user_information.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  var _changeName = false;
  final _titleController = TextEditingController();
  var _isLoading = false; 

  void _changeUsername () async {
    setState(() {
      _isLoading = true;
      FocusScope.of(context).unfocus();
    });
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    
    ref.read(userProvider.notifier).signup(
      You(email: user.email!, id: user.uid, username: _titleController.text, password: userData.data()!['password'])
    );

    await FirebaseFirestore.instance.collection('Users').doc(user.uid).update(
      {
        'email' : user.email,
        'id' : user.uid,
        'username' : _titleController.text,
        'password' : userData.data()!['password']
      }
    );

    final groupData = await FirebaseFirestore.instance.collection('Group').get();
    final groupDocs = groupData.docs;
    final jgroups = groupDocs.where((gdoc) => gdoc.data()['memberId'].contains(user.uid));
    for (final jgroup in jgroups) {
      
      final List<dynamic> editedMemberId = jgroup.data()['memberId'];
      final userIndex = editedMemberId.indexOf(user.uid);
      final List<dynamic> editedMember = jgroup.data()['member'];
      editedMember.remove(editedMember[userIndex]);
      editedMemberId.remove(editedMemberId[userIndex]);
      await FirebaseFirestore.instance.collection('Group').doc(jgroup.data()['id']).update(
        {
          'id' : jgroup.data()['id'],
          'groupname' : jgroup.data()['groupname'],
          'member' : [
            ...editedMember,
            _titleController.text,
          ],
          'memberId' : [
            ...editedMemberId,
            user.uid,
          ],
          'time' : jgroup.data()['time'],
        }
      );
      ref.watch(groupProvider.notifier).changeName(
        Group(
          groupname: jgroup.data()['groupname'],
          id: jgroup.data()['id'],
          member: [
            ...editedMember,
            _titleController.text,
          ],
          memberId: [
            ...editedMemberId,
            user.uid,
          ],
          time: jgroup.data()['time'],
        )
      );
    }

    setState(() {
      _changeName = false;
      _isLoading = false;
    });

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
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading 
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            children: [
              const UserInformation(),
              const SizedBox(height: 16,),
              TextButton(
                onPressed: () {
                  setState(() {
                    _changeName = !_changeName;
                  });
                }, 
                child: const Text(
                  'ユーザーネームの変更',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              if (_changeName)
                const SizedBox(height: 16,),
              if (_changeName)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'ユーザーネームを変更'
                          ),
                          controller: _titleController,
                        ),
                      ),
                      const SizedBox(width: 8,),
                      TextButton(
                        onPressed: _isLoading ? null : _changeUsername, 
                        child: const Text('変更'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16,),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                }, 
                child: const Text(
                  'ログアウト',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}