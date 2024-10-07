import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Light Gray for the background
                  // Customizing border with different styles
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
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Light Gray for the background
                  // Customizing border with different styles
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
                  onPressed: () {
                    // TODO: Implement login functionality
                    String username = _usernameController.text;
                    String password = _passwordController.text;
                    print('Username: $username, Password: $password');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFFF33638), // Use primary color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                  child: Text('Log In',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)), // Customize text style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
