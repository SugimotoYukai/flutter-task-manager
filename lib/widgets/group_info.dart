import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/providers/group_provider.dart';

class GroupInformation extends ConsumerStatefulWidget {
  const GroupInformation({
    super.key,
    required this.group,
    });

    final Group group;

    @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _GroupInformation();
  }

}

class _GroupInformation extends ConsumerState<GroupInformation> {

  void _getInformation () async {
    final groupData = await FirebaseFirestore.instance.collection('Group').doc(widget.group.id).get();
    final memberId = groupData.data()!['memberId'];
    final id = widget.group.id;
    final groupname = groupData.data()!['groupname'];
    final member = groupData.data()!['member'];
    final time = groupData.data()!['time'];
    ref.read(groupInfoProvider.notifier).getInfo(
      Group(groupname: groupname, id: id, member: member, memberId: memberId, time: time)
    );
  }

  @override
  void initState() {
    super.initState();
    _getInformation();
  }

  @override
  Widget build(BuildContext context) {
    final groupInfo = ref.watch(groupInfoProvider);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'グループ情報',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onBackground
              ),
            ),
            const SizedBox(height: 16,),
            Row(
              children: [
                const Text(
                  'グループID :',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  groupInfo.id,
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                const Text(
                  'グループ名 :',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  groupInfo.groupname,
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                const Text(
                  'メンバー数 :',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  groupInfo.member.length.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}