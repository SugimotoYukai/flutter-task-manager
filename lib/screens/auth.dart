import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:tansu_kanri/providers/user_provider.dart';
import 'package:tansu_kanri/models/user.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen>{
  final _formkey = GlobalKey<FormState>();
  var isLogin = false;
  var isLoading = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';

  void _submit () async {

    setState(() {
      isLoading = true;
      FocusScope.of(context).unfocus();
    });

    final isValid = _formkey.currentState!.validate();

    if (!isValid) {
      setState(() {
        isLoading = false;
      });
      return;
      }

      _formkey.currentState!.save();

      final firebase = FirebaseAuth.instance;

  try {
    if (isLogin) {
      await firebase.signInWithEmailAndPassword(
        email: _enteredEmail, 
        password: _enteredPassword
      );
    } else {
      await firebase.createUserWithEmailAndPassword(
        email: _enteredEmail, 
        password: _enteredPassword
      );
      final you = You(
        email: _enteredEmail, 
        id: firebase.currentUser!.uid, 
        username: _enteredUsername, 
        password: _enteredPassword
      );
      ref.read(userProvider.notifier).signup(you);
      await FirebaseFirestore.instance.collection('Users').doc(firebase.currentUser!.uid).set(
        {
          'email' : _enteredEmail,
          'password' : _enteredPassword,
          'username' : _enteredUsername,
          'id' : firebase.currentUser!.uid,
        }
      );
    }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('すでに存在するアカウントです')
          )
        );
      }
      if (error.code == 'user-not-found' || error.code == 'wrong-password' || error.code == 'invalid-email') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メールアドレスまたはパスワードが間違っています')
          )
        );
      }
      else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('不明なエラー')
          )
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '共有タスク管理'
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 72, 68, 68),
              Colors.grey
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 60,
            ),
            child: Card(
              color: Colors.white,
              child: Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'ログイン' : 'アカウント作成',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 9, 157, 173),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Eメール'
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (
                            value == null ||
                            value.trim().isEmpty
                          ) {
                            return 'メールアドレスが入力されていません';
                          }
                          if (!value.contains('@')) {
                            return '有効なメールアドレスを入力してください';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'パスワード'
                        ),
                        obscureText: true,
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (
                            value == null ||
                            value.trim().length < 6
                          ) {
                            return '6文字以上のパスワードを入力してください';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                      ),
                      if (!isLogin)
                      const SizedBox(height: 16,),
                      if (!isLogin)
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'ユーザーネーム'
                        ),
                        validator: (value) {
                          if (
                            value == null ||
                            value.trim().isEmpty
                          ) {
                            return 'ユーザーネームを入力してください';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredUsername = newValue!;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit, 
                        child: Text(
                          isLogin
                          ? 'ログイン'
                          : 'アカウントを作成'
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        }, 
                        child: Text(
                          isLogin
                          ? 'まだアカウントを持っていない'
                          : 'すでにアカウントを持っている'
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}