import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/providers/group_provider.dart';
import 'package:tansu_kanri/widgets/group_info.dart';
import 'package:tansu_kanri/widgets/member_list.dart';

class GroupSettingScreen extends ConsumerStatefulWidget {
  const GroupSettingScreen({
    super.key,
    required this.group,
    });

  final Group group;

  @override
  ConsumerState<GroupSettingScreen> createState() => _GroupSettingScreenState();
}

class _GroupSettingScreenState extends ConsumerState<GroupSettingScreen> {
  var _isLoading = false;
  var _changeName = false;
  final _titleController = TextEditingController();

  void _changeGroupName () async {
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
    final newGroup = ref.read(groupInfoProvider.notifier).getInfo(
      Group(
      groupname: _titleController.text, 
      id: widget.group.id, 
      member: widget.group.member, 
      memberId: widget.group.memberId, 
      time: widget.group.time)
    );
    await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).update(
      {
        'groupname' : _titleController.text,
        'id' : widget.group.id,
        'member' : widget.group.member,
        'memberId' : widget.group.memberId,
        'time' : widget.group.time,
      }
    );
    ref.read(groupProvider.notifier).renewalGroup(newGroup);

    setState(() {
      _isLoading = false;
      _changeName = false;
    });
  }

  void _goodbyeGroup () async {

    setState(() {
      _isLoading = true;
    });

    try{
    final user = FirebaseAuth.instance.currentUser!;
    final memberIndex = widget.group.memberId.indexOf(user.uid);
    widget.group.member.remove(widget.group.member[memberIndex]);

    ref.read(groupProvider.notifier).goodbyeGroup(widget.group);

    await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).update(
      {
        'id' : widget.group.id,
        'groupname' : widget.group.groupname,
        'member' : widget.group.member,
        'memberId' : widget.group.memberId.where((m) => m != user.uid).toList(),
        'time' : widget.group.time,
      }
    );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不明なエラー'))
      );
    }

    setState(() {
      _isLoading = false;
    });

    // ignore: use_build_context_synchronously
    Navigator.of(context).popUntil((route) => route.isFirst);

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('グループの設定'),
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
              GroupInformation(group: widget.group),
              const SizedBox(height: 16,),
              MemberList(group: widget.group),
              const SizedBox(height: 16,),
              TextButton(
                onPressed: () {
                  setState(() {
                    _changeName = !_changeName;
                  });
                }, 
                child: const Text(
                  'グループ名を変える',
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
                              labelText: 'グループ名を変更'
                            ),
                            controller: _titleController,
                          ),
                        ),
                        const SizedBox(width: 8,),
                        TextButton(
                          onPressed: _isLoading ? null : _changeGroupName, 
                          child: const Text('変更'),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 16,),
              TextButton(
                onPressed: _isLoading ? null : _goodbyeGroup, 
                child: const Text(
                  'グループを抜ける',
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