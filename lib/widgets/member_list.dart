import 'package:flutter/material.dart';
import 'package:tansu_kanri/models/group.dart';

class MemberList extends StatelessWidget{
  const MemberList({super.key, required this.group});

  final Group group;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('メンバー一覧'),
              for (final member in group.member)
              ListTile(
                title: Text(member),
              )
            ],
          ),
        )
      ),
    );
  }
}