import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:tansu_kanri/models/user.dart';
import 'package:tansu_kanri/providers/user_provider.dart';

class UserInformation extends ConsumerStatefulWidget {
  const UserInformation({
    super.key,
    });

    @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _UserInformation();
  }

}

class _UserInformation extends ConsumerState<UserInformation> {
  final _user = FirebaseAuth.instance.currentUser!;

  void _getInformation () async {
    final userData = await FirebaseFirestore.instance.collection('Users').doc(_user.uid).get();
    final email = _user.email!;
    final id = _user.uid;
    final username = userData.data()!['username'];
    final password = userData.data()!['password'];
    ref.read(userProvider.notifier).signup(
      You(email: email, id: id, username: username, password: password)
    );
  }

  @override
  void initState() {
    super.initState();
    _getInformation();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'ユーザー情報',
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
                  'ユーザーID :',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  user.id,
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                const Text(
                  'ユーザーネーム :',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  user.username,
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                const Text(
                  'メールアドレス :',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                const SizedBox(width: 8,),
                Text(
                  user.email,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}