import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/providers/group_provider.dart';

import 'package:tansu_kanri/screens/add.dart';
import 'package:tansu_kanri/screens/join.dart';
import 'package:tansu_kanri/screens/setting.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/widgets/group_list_widget.dart';

class GroupScreen extends ConsumerStatefulWidget{
  const GroupScreen({super.key});

  @override
  ConsumerState<GroupScreen> createState() {
    return _GroupScreenState();
  }
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  final _user = FirebaseAuth.instance.currentUser!;
  var isLoading = false;

  void _getData () async {
    setState(() {
      isLoading = true;
    });

    final groupData = await FirebaseFirestore.instance.collection('Group').get();
    final jgroups = groupData.docs.where((group) => group.data()['memberId'].contains(_user.uid));
    for (final jgroup in jgroups) {
      final groupname = jgroup['groupname'];
      final id = jgroup['id'];
      final member = jgroup['member'];
      final memberId = jgroup['memberId'];
      final time = jgroup['time'];

      ref.watch(groupProvider.notifier).addGroup(
        Group(groupname: groupname, id: id, member: member, memberId: memberId, time: time)
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupProvider);
    final List<Group> joinedGroup = groups.where((group) => group.memberId.contains(_user.uid)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('グループ一覧'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AddScreen())
              );
            }, 
            icon: const Icon(Icons.add)
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const JoinScreen())
              );
            }, 
            icon: const Icon(Icons.people),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingScreen())
              );
            }, 
            icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(),) : GroupList(groups: joinedGroup)
    );
  }
}