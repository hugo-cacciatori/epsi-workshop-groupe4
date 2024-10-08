import 'package:alertchain/views/auth_page.dart';
import 'package:alertchain/views/user_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'views/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlertChain',
      theme: ThemeData(
        primaryColor: Color(0xFFF33638),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
      ),
      home: AuthPage(), // Direct access to AdminDashboardPage
    );
  }
}
