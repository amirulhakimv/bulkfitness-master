import 'package:bulkfitness/pages/auth/login_page.dart';
import 'package:bulkfitness/pages/first_page.dart';
import 'package:bulkfitness/pages/intro_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA9QyuARERCtRQJHCr64Qj1UZgzvbycs4k",
            authDomain: "bulkfitness-70d48.firebaseapp.com",
            projectId: "bulkfitness-70d48",
            storageBucket: "bulkfitness-70d48.firebasestorage.app",
            messagingSenderId: "576654875808",
            appId: "1:576654875808:web:80d419856226c3e227bdc5",
            measurementId: "G-3F7SFZ0HSB"));
  } else {
    Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: IntroPage(),
      home: const IntroPage(),
      //home: LoginPage(),
      theme: lightMode,
    );
  }
}
