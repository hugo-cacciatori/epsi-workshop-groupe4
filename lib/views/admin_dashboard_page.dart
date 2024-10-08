import 'package:alertchain/views/employee_form_page.dart';
import 'package:alertchain/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AdminDashboardPage extends StatefulWidget {
  final User currentUser; // Changed to accept a User object

  AdminDashboardPage({required this.currentUser});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late String organizationName = '';
  List<Map<String, dynamic>> employees = []; // List to store employee data

  @override
  void initState() {
    super.initState();
    fetchOrganizationData(); // Fetch organization data based on user
  }

  Future<void> fetchOrganizationData() async {
    // Fetch organization data
    DocumentSnapshot orgDoc = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(widget.currentUser.organizationID)
        .get();
    if (orgDoc.exists) {
      setState(() {
        organizationName = orgDoc['organizationName'];
      });
    }

    // Fetch employees for this organization, excluding those who are SuperAdmin
    QuerySnapshot empQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('organizationID', isEqualTo: widget.currentUser.organizationID)
        .where('isSuperAdmin', isEqualTo: false) // Exclude super admins
        .get();

    setState(() {
      // Store all relevant employee data
      employees = empQuery.docs.map((doc) {
        return {
          'id': doc.id, // Store document ID
          'firstName': doc['firstName'],
          'lastName': doc['lastName'],
          'email': doc['email'], // Add email
          'phoneNumber': doc['phoneNumber'], // Add phone number
          'departmentName': doc['departmentName'], // Add department name
        };
      }).toList();
    });
  }

  void onEmployeeUpdated() {
    fetchOrganizationData(); // Refresh employee list after add/edit/delete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFF33638),
        iconTheme:
            IconThemeData(color: Colors.white), // Set icon color to white
      ),
      drawer: AppDrawer(
        firstName: widget.currentUser.firstName,
        lastName: widget.currentUser.lastName,
        organizationName: organizationName,
      ), // Use AppDrawer in the scaffold
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Combined welcome message with visual enhancement
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome ${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'My Employees at $organizationName:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Employee list or placeholder if empty
            Expanded(
              child: employees.isNotEmpty
                  ? ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return Card(
                          color: Colors
                              .grey[200], // Background color for the cards
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${employee['firstName']} ${employee['lastName']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Tooltip(
                                      message: 'Edit this employee',
                                      child: IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EmployeeFormPage(
                                                organizationID: widget
                                                    .currentUser.organizationID,
                                                employee:
                                                    employee, // Pass the entire employee object
                                                onEmployeeUpdated:
                                                    onEmployeeUpdated, // Use the onEmployeeUpdated callback
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Space between button and tooltip
                                    Tooltip(
                                      message: 'Delete this employee',
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text(
                                                  'Are you sure you want to delete ${employee['firstName']} ${employee['lastName']}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    // Delete employee from Firestore
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(employee[
                                                            'id']) // Use employee's document ID
                                                        .delete()
                                                        .then((_) {
                                                      onEmployeeUpdated(); // Refresh the list after deletion
                                                    });
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                          context)
                                                      .pop(), // Close the dialog
                                                  child: Text('No'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add an employee to start',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(
                              height:
                                  20), // Adjust spacing between text and buttons
                        ],
                      ),
                    ),
            ),

            // Visual separation between the list and buttons
            SizedBox(height: 10), // Space between list and button area
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors
                    .grey[200], // Light background color for the button area
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                  bottom: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Add a new employee',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green[800], // Set green background
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8), // Space between icon and text
                            Text('Add Employee',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmployeeFormPage(
                                organizationID: widget.currentUser
                                    .organizationID, // Pass organizationID to new page
                                onEmployeeUpdated:
                                    onEmployeeUpdated, // Callback for refresh
                              ),
                            ),
                          ).then((_) {
                            fetchOrganizationData(); // Refresh list on return
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 20), // Space between buttons
                    Tooltip(
                      message: 'Add a batch of employees',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green[800], // Set green background
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.group, color: Colors.white),
                            SizedBox(width: 8), // Space between icon and text
                            Text('Add Batch',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        onPressed: () {
                          // TODO: Implement add batch employees functionality
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
