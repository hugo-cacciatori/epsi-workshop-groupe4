import 'package:alertchain/views/auth_page.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  // await Firebase.initializeApp(); // Initialize Firebase/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlertChain',
      theme: ThemeData(
        primaryColor: Color(0xFFF33638), // Primary Color
        scaffoldBackgroundColor: Color(0xFFFFFFFF), // White background
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5F5), // Light Gray for input fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Color(0xFF757575)), // Gray border
          ),
        ),
      ),
      home: AuthPage(),
    );
  }
}
