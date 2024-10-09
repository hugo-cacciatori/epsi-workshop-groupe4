import 'package:alertchain/helpers/string_helper.dart';
import 'package:alertchain/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../models/user.dart'; // Assuming you have a User model

class UserDashboardPage extends StatefulWidget {
  final User currentUser; // Accepting a User object in the constructor

  // Constructor
  UserDashboardPage({required this.currentUser});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  String organizationName = ''; // To store the organization name
  bool isToggleActive = false; // To manage the toggle state
  double buttonScale = 1.0; // Scale factor for the button
  List<String> currentAlerts = []; // To store current alerts
  List<User> certifiedEmployees = []; // To store certified employees

  @override
  void initState() {
    super.initState();
    fetchOrganizationName(); // Fetch organization info when page loads
    fetchCurrentAlerts(); // Fetch current alerts
    fetchCertifiedEmployees(); // Fetch certified employees
  }

  // Method to fetch organization data from Firestore using the organizationID
  Future<void> fetchOrganizationName() async {
    try {
      // Get organization document from Firestore
      DocumentSnapshot orgDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.currentUser.organizationID)
          .get();

      if (orgDoc.exists) {
        setState(() {
          organizationName = orgDoc['organizationName'] ??
              'Unknown Organization'; // Store organization name
        });
      } else {
        setState(() {
          organizationName = 'Unknown Organization'; // Default if not found
        });
      }
    } catch (e) {
      print('Error fetching organization: $e');
      setState(() {
        organizationName = 'Error fetching organization';
      });
    }
  }

  // Method to fetch current alerts
  Future<void> fetchCurrentAlerts() async {
    try {
      QuerySnapshot alertsSnapshot = await FirebaseFirestore.instance
          .collection('alerts')
          .where('organizationID', isEqualTo: widget.currentUser.organizationID)
          .get();

      setState(() {
        currentAlerts =
            alertsSnapshot.docs.map((doc) => doc['message'] as String).toList();
      });
    } catch (e) {
      print('Error fetching alerts: $e');
    }
  }

  // Method to fetch certified employees
  Future<void> fetchCertifiedEmployees() async {
    try {
      // Fetch employees for this organization, excluding those who are SuperAdmin
      QuerySnapshot employeesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('organizationID', isEqualTo: widget.currentUser.organizationID)
          .where('isSuperAdmin', isEqualTo: false) // Exclude super admins
          .where('isCertified', isEqualTo: true) // Only certified users
          .get();

      // Map the fetched documents to User objects
      certifiedEmployees = employeesSnapshot.docs
          .map((doc) => User.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id)) // Use fromFirestore
          .toList();

      // Update the UI state after fetching certified employees
      setState(() {});
    } catch (e) {
      print('Error fetching certified employees: $e');
    }
  }

  // Logic to send a notification to all users
  void sendNotification() {
    // Removed Snackbar as requested
  }

  // Function to show confirmation dialog
  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text(
            'Pressing the button will send a notification to many users, do you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              sendNotification(); // Send notification after confirmation
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel action
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Function to build an avatar
  Widget buildAvatar(User employee) {
    return Tooltip(
      message:
          '${capitalize(employee.firstName)} ${capitalize(employee.lastName)}',
      child: CircleAvatar(
        radius: 40, // Increased radius for bigger circles
        backgroundImage: employee.profilePictureUrl != null &&
                employee.profilePictureUrl.isNotEmpty
            ? NetworkImage(employee.profilePictureUrl)
            : null,
        backgroundColor: Colors
            .blueAccent, // Default background color when no profile picture
        child: employee.profilePictureUrl == null ||
                employee.profilePictureUrl.isEmpty
            ? Text(
                '${capitalize(employee.firstName[0])}${capitalize(employee.lastName[0])}', // Use initials
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white), // Updated font size and color
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var sizeRatio = 1.5;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFF33638),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        firstName: widget.currentUser.firstName,
        lastName: widget.currentUser.lastName,
        organizationName:
            organizationName, // Pass the retrieved organization name
      ),
      body: AnimatedContainer(
        duration:
            Duration(milliseconds: 200), // Smooth background color transition
        color: Colors.white, // Set the background color to default white
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Instructions section inside a grey bubble
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Please follow the instructions carefully before pressing the button.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30), // Space between instruction and button

            // Big Red Button with feedback animation
            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  buttonScale = 0.95; // Scale down on tap
                });
              },
              onTapUp: (_) {
                setState(() {
                  buttonScale = 1.0; // Scale back to original size
                });
                if (isToggleActive) {
                  sendNotification(); // Send notification if toggle is active
                } else {
                  showConfirmationDialog(); // Show confirmation if toggle is off
                }
              },
              onTapCancel: () {
                setState(() {
                  buttonScale = 1.0; // Reset scale if tap is canceled
                });
              },
              child: Transform.scale(
                scale:
                    buttonScale, // Apply scale transformation for center scaling
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 40 * sizeRatio,
                      horizontal: 60 *
                          sizeRatio), // Increased padding for a larger button
                  decoration: BoxDecoration(
                    color: Colors.red[700], // Dark red for an intense look
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.2), // Subtle shadow color
                        spreadRadius: 2, // How much the shadow spreads
                        blurRadius: 6, // Blur radius for softness
                        offset: Offset(0, 4), // Offset for the shadow
                      ),
                    ],
                  ),
                  child: Text(
                    'SEND\nALERT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          32 * sizeRatio, // Increased font size for visibility
                      fontWeight: FontWeight.bold,
                      height: 1.2, // Adjust line height for better spacing
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30), // Space between button and toggle section

            // Toggle Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'I understand that pressing the button will notify every certified user',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Switch(
                  value: isToggleActive,
                  onChanged: (bool value) {
                    setState(() {
                      isToggleActive = value; // Update toggle state
                    });
                  },
                  activeColor: Colors.green, // Toggle color when active
                  inactiveThumbColor: Colors.grey, // Toggle color when inactive
                ),
              ],
            ),

            SizedBox(height: 30), // Space between toggle and alerts section

            // Current Alerts Section
            if (widget.currentUser.isManager ||
                widget.currentUser.isCertified) ...[
              Text(
                'Current Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10), // Space between title and alerts
              if (currentAlerts.isEmpty) ...[
                Text(
                  'No current alerts in $organizationName.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ] else ...[
                Column(
                  children: currentAlerts
                      .map((alert) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              alert,
                              style: TextStyle(fontSize: 16),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],

            SizedBox(
                height:
                    30), // Space between alerts and certified employees section

            // Certified Employees Section
            Text(
              'Certified Employees in $organizationName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // Space between title and employee list
            Container(
              height: 80, // Set a fixed height for the scrolling list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: certifiedEmployees.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: buildAvatar(certifiedEmployees[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
