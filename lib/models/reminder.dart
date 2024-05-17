import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReminderColor {
  red, blue, yellow, green, purple, grey, pink, lightblue, orange
}

const reminderColors = {
  ReminderColor.red : Color.fromARGB(255, 217, 30, 17),
  ReminderColor.blue : Color.fromARGB(255, 33, 68, 243),
  ReminderColor.yellow : Colors.yellow,
  ReminderColor.green : Color.fromARGB(255, 12, 122, 15),
  ReminderColor.purple : Colors.purple,
  ReminderColor.grey : Colors.grey,
  ReminderColor.pink : Color.fromARGB(255, 233, 30, 199),
  ReminderColor.lightblue : Colors.lightBlue,
  ReminderColor.orange : Colors.orange,
};
 
class Reminder {
  Reminder({
    required this.id,
    required this.groupId,
    required this.title,
    required this.colorname,
    this.deadline,
    required this.createTime,
    required this.creatorname,
    required this.creatorId,
    this.doMember = const [],
    this.doMemberId = const [],
  });
  final String id;
  final String groupId;
  final String title;
  final String colorname;
  Timestamp? deadline; 
  final Timestamp createTime;
  final String creatorname;
  final String creatorId;
  final List<dynamic> doMember;
  final List<dynamic> doMemberId;
}