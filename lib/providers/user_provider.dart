import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tansu_kanri/models/user.dart';

class UserNotifier extends StateNotifier<You> {
  UserNotifier() : super(
    const You(email: '', id: '', password: '', username: '')
  );

  void signup (You you) {
    state = you;
  }

}

final userProvider = StateNotifierProvider<UserNotifier, You>((ref) => UserNotifier());