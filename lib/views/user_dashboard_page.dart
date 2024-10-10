import 'package:alertchain/helpers/string_helper.dart';
import 'package:alertchain/models/alert.dart';
import 'package:alertchain/widgets/alert_card.dart';
import 'package:alertchain/widgets/alert_popup.dart';
import 'package:alertchain/widgets/app_drawer.dart';
import 'package:alertchain/widgets/confirmation_popup.dart';
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
  List<Alert> currentAlerts = []; // Update to store Alert objects
  Set<String> displayedAlertIds = {}; // Track displayed alert IDs

  List<User> certifiedEmployees = []; // To store certified employees

  Timestamp?
      latestAlertTimestamp; // Add this to track the latest alert timestamp
  bool isInitialLoad = true; // New flag to track if it's the initial load

  @override
  void initState() {
    super.initState();
    fetchOrganizationName(); // Fetch organization info when page loads
    listenForCurrentAlerts(); // Start listening for current alerts
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

  void listenForCurrentAlerts() {
    FirebaseFirestore.instance
        .collection('alerts')
        .where('organizationID', isEqualTo: widget.currentUser.organizationID)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Alert> newAlerts = snapshot.docs
          .map((doc) =>
              Alert.fromFirestore(doc)) // Pass the DocumentSnapshot directly
          .toList();

      setState(() {
        currentAlerts = newAlerts;
      });

      // Get the latest alert's timestamp
      if (newAlerts.isNotEmpty) {
        Timestamp alertTimestamp = newAlerts.first.timestamp;

        if (isInitialLoad) {
          // On initial load, just update the timestamp but do not show the popup
          latestAlertTimestamp = alertTimestamp;
          isInitialLoad = false; // Mark that initial load is complete
        } else if (alertTimestamp.compareTo(latestAlertTimestamp!) > 0) {
          // Check if it's a new alert after the page load
          setState(() {
            latestAlertTimestamp =
                alertTimestamp; // Update the latest alert timestamp
          });

          // Check if the alert has already been displayed
          if (!displayedAlertIds.contains(newAlerts.first.id)) {
            displayedAlertIds
                .add(newAlerts.first.id); // Mark this alert as displayed

            // If the current user is the sender of the alert, show the confirmation popup
            if (newAlerts.first.senderID == widget.currentUser.id) {
              showDialog(
                context: context,
                builder: (context) {
                  return ConfirmationPopup(
                      certifiedEmployees: certifiedEmployees);
                },
              );
            }
            // If the user is certified or a manager, show the alert popup
            else if (widget.currentUser.isCertified ||
                widget.currentUser.isManager) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertPopup(
                    alert: newAlerts.first,
                    currentUser: widget.currentUser,
                  );
                },
              );
            }
            // If the user is not authorized, no popup is shown
            else {
              print('Current user is not authorized to view this alert.');
            }
          }
        }
      }
    }, onError: (error) {
      print('Error listening for alerts: $error');
    });
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

  Future<void> sendAlert() async {
    try {
      await FirebaseFirestore.instance.collection('alerts').add({
        'organizationID': widget.currentUser.organizationID,
        'timestamp': FieldValue
            .serverTimestamp(), // Server-side timestamp for consistency
        'senderID': widget.currentUser.id,
        'senderDepartmentName': widget.currentUser.departmentName,
        'senderFirstName': widget.currentUser.firstName,
        'senderLastName': widget.currentUser.lastName,
      });

      print('Notification sent for the whole organization.');
    } catch (e) {
      print('Error sending notification: $e');
    }
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
              sendAlert(); // Send notification after confirmation
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

  Widget buildUserAvatar({
    required String firstName,
    required String lastName,
    required String? profilePictureUrl,
    double radius = 40,
  }) {
    return Tooltip(
      message: '${capitalize(firstName)} ${capitalize(lastName)}',
      child: CircleAvatar(
        radius: radius,
        backgroundImage:
            (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                ? NetworkImage(profilePictureUrl)
                : null,
        backgroundColor: Colors.blueAccent,
        child: (profilePictureUrl == null || profilePictureUrl.isEmpty)
            ? Text(
                '${capitalize(firstName[0])}${capitalize(lastName[0])}', // Use initials
                style: TextStyle(
                  fontSize: 20, // Smaller font size for alert avatars
                  color: Colors.white,
                ),
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
      body: SingleChildScrollView(
        child: AnimatedContainer(
          duration:
              Duration(milliseconds: 200), // Smooth background color transition
          color: Colors.white, // Set the background color to default white
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Current Alerts Section
              if (widget.currentUser.isManager ||
                  widget.currentUser.isCertified ||
                  true) ...[
                Text(
                  'Current Alerts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (currentAlerts.isEmpty) ...[
                  Text(
                    'No current alerts in $organizationName.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ] else ...[
                  Container(
                    height: 142, // Set a fixed height for the horizontal list
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentAlerts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0), // Spacing between cards
                          child: AlertCard(
                              alert: currentAlerts[index]), // Build alert card
                        );
                      },
                    ),
                  ),
                ],
              ],
              SizedBox(height: 15),
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
                    sendAlert(); // Send notification if toggle is active
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
                        fontSize: 32 *
                            sizeRatio, // Increased font size for visibility
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
                    inactiveThumbColor:
                        Colors.grey, // Toggle color when inactive
                  ),
                ],
              ),
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
                      child: buildUserAvatar(
                        firstName: certifiedEmployees[index].firstName,
                        lastName: certifiedEmployees[index].lastName,
                        profilePictureUrl:
                            certifiedEmployees[index].profilePictureUrl,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
