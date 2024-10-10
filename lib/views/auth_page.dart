import 'package:alertchain/views/admin_dashboard_page.dart';
import 'package:alertchain/views/user_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    // Retrieve the email and password
    _emailController.text = "hugo.cacciatori@gmail.com";
    // lemecdelinfra@cloud.com // mon user non certifié
    // hugo.cacciatori@gmail.com // mon superadmin
    // certifieduser@gmail.com // mon user certifié
    _passwordController.text = "test";
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Encode the password using SHA-256
    String passwordHash = sha256.convert(utf8.encode(password)).toString();

    try {
      // Query Firestore to find the user with the matching email and password hash
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: passwordHash)
          .get();

      // Check if the user exists
      if (userSnapshot.docs.isNotEmpty) {
        // Successfully logged in
        var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        String currentUserID =
            userSnapshot.docs.first.id; // Get the document ID

        // Create User object using the factory constructor
        User currentUser = User.fromFirestore(userData, currentUserID);

        if (currentUser.isSuperAdmin) {
          // Navigate to the Admin Dashboard if user is SuperAdmin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardPage(
                currentUser: currentUser, // Pass the complete User object
              ),
            ),
          );
        } else if (currentUser.isAdmin) {
          // Navigate to the Admin Dashboard if user is Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardPage(
                currentUser: currentUser, // Pass the complete User object
              ),
            ),
          );
        } else {
          // Navigate to the User Dashboard (you will need to create this page)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => UserDashboardPage(
                      currentUser: currentUser,
                    )), // Placeholder for user dashboard
          );
        }
      } else {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid email or password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the logo using Image widget
              Container(
                width: 300, // Logo width
                height: 300, // Logo height
                child: Image.asset(
                  'assets/AlertChain.png',
                  fit: BoxFit.contain, // Maintain aspect ratio
                ),
              ),
              SizedBox(height: 20), // Space between logo and form

              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email', // Label for the email field
                  hintText: 'Enter your email', // Hint text updated to email
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Light Gray for the background
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.transparent), // No border when unfocused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Color(0xFFF33638),
                        width: 2.5), // Red border when focused
                  ),
                ),
              ),
              SizedBox(height: 16), // Space between fields

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password', // Label for the password field
                  hintText: 'Enter your password', // Hint text remains the same
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Light Gray for the background
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.transparent), // No border when unfocused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Color(0xFFF33638),
                        width: 2.5), // Red border when focused
                  ),
                ),
              ),
              SizedBox(height: 20), // Space between fields and button

              // Customizable login button
              Container(
                width: 150, // Set a width for the button
                height: 50, // Customize height
                child: ElevatedButton(
                  onPressed: _login, // Call the login function
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFFF33638), // Use primary color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ), // Customize text style
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
