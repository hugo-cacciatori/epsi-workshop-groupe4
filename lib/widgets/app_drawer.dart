// lib/widgets/app_drawer.dart
import 'package:alertchain/views/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // If you need Firestore for logout logic

class AppDrawer extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String organizationName;

  const AppDrawer({
    required this.firstName,
    required this.lastName,
    required this.organizationName,
  });

  void _logout(BuildContext context) async {
    // Add custom logout logic here if needed
    // For example, clear any stored user data or reset application state

    // Navigate to the AuthPage without carrying user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => AuthPage()), // Navigate to AuthPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // White with transparency
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with red background
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF33638), // Red background color
              ),
              accountName: Text(
                '$firstName $lastName',
                style: TextStyle(color: Colors.white), // White text on red
              ),
              accountEmail: Text(
                organizationName,
                style: TextStyle(color: Colors.white), // White text
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '${firstName[0]}${lastName[0]}',
                  style: TextStyle(fontSize: 40.0, color: Color(0xFFF33638)),
                ),
              ),
            ),

            // Drawer items (add more if needed)
            ListTile(
              leading: Icon(Icons.home, color: Colors.black),
              title: Text('Dashboard', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            Divider(), // Optional divider between sections

            // Logout option
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                _logout(context); // Call logout function
              },
            ),
          ],
        ),
      ),
    );
  }
}
