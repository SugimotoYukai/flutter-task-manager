import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  const Group({
    required this.groupname,
    required this.id,
    required this.member,
    required this.memberId,
    required this.time,
  });
  final String groupname;
  final String id;
  final List<dynamic> member;
  final List<dynamic> memberId;
  final Timestamp time;
}