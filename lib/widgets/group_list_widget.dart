import 'package:flutter/material.dart';
import 'package:tansu_kanri/models/group.dart';
import 'package:tansu_kanri/screens/reminders.dart';

class GroupList extends StatelessWidget {
  const GroupList({
    super.key,
    required this.groups,
    });

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Center(
              child: Text('グループを追加してください'),
            );
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (ctx, index) => 
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => RemindersScreen(group: groups[index]))
            );
          },
          child: ListTile(
            title: Text(
              groups[index].groupname,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
        ),
      )
    );
  }
}