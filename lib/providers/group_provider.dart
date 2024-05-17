import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tansu_kanri/models/group.dart';

class GroupNotifier extends StateNotifier<List<Group>>{
  GroupNotifier() : super(
    []
  );

   void addGroup (Group group) {
    if (state.isEmpty) {
      state = [
      ...state,
      group,
    ];
    } else {
      if (state.where((g) => g.id == group.id).toList().isEmpty) {
        state = [
          ...state,
          group,
        ];
      }
    }


   }

   void renewalGroup (Group group) {
    state = state.where((g) => g.id != group.id).toList();

    state = [
      ...state,
      group,
    ];
   }

   void goodbyeGroup (Group group) {
    state = state.where((g) => g.id != group.id).toList();
   }

   void changeName (Group group) {
    state = state.where((g) => g.id != group.id).toList();
    state = [
      ...state,
      group
    ];
   }
}

final groupProvider = StateNotifierProvider<GroupNotifier, List<Group>>(
  (ref) => GroupNotifier()
);

class GroupInfoNotifier extends StateNotifier<Group> {
  GroupInfoNotifier() : super(
    Group(groupname: '', id: '', member: [], memberId: [], time: Timestamp.now())
  );

  Group getInfo (Group group) {
    state = group;

    return state;
  }
}

final groupInfoProvider = StateNotifierProvider<GroupInfoNotifier, Group>((ref) => GroupInfoNotifier());