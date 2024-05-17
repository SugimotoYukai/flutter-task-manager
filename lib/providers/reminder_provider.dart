import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/models/reminder.dart';

class ReminderNotifier extends StateNotifier<List<Reminder>> {
  ReminderNotifier() : super([]);

  void scanReminder (Reminder reminder) {
    if (state.isEmpty) {
      state = [
      reminder,
      ...state,
    ];
    }
    if (state.isNotEmpty) {
      if (state.where((rem) => rem.id == reminder.id).toList().isEmpty) {
        state = [
          reminder,
          ...state,
        ];
      }
    final filterRemind = state.firstWhere((rem) => rem.id == reminder.id);
    if (filterRemind.id != reminder.id) {
      state = [
        reminder,
        ...state,
      ];
    }
    }
  }

  void addReminder(Reminder reminder) {
    state = [
      reminder,
      ...state,
    ];
  }

  void deleteReminder (Reminder reminder) {
    state = state.where((rem) => rem.id != reminder.id).toList();
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, List<Reminder>>(
  (ref) => ReminderNotifier()
);