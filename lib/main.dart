import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:tansu_kanri/firebase_options.dart';
import 'package:tansu_kanri/screens/auth.dart';
import 'package:tansu_kanri/screens/groups.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]).then((fn) {
    runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Flutter Share Reminder App',
        theme: ThemeData().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 11, 222, 255))
        ),
        home: const MyApp(),
      ),
    )
  );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, stream) {
            if (stream.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (stream.hasData) {
              return const GroupScreen();
            }
            return const AuthScreen();
          }
        );
  }
}