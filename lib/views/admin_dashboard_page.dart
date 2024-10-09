import 'package:alertchain/helpers/string_helper.dart';
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
          'isCertified': doc['isCertified'] ?? false, // Add isCertified field
          'isManager': doc['isManager'] ?? false, // Add isManager field
          'isAdmin': doc['isAdmin'] ?? false, // Add isAdmin field
        };
      }).toList();
    });
  }

  void onEmployeeUpdated() {
    fetchOrganizationData(); // Refresh employee list after add/edit/delete
  }

  Future<void> toggleField(
      String employeeId, String field, bool currentValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(employeeId)
          .update({
        field: !currentValue, // Toggle the current value
      });
      onEmployeeUpdated(); // Refresh the list after toggling
    } catch (e) {
      print('Error toggling field: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle field: $e')),
      );
    }
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
                    'Welcome ${capitalize(widget.currentUser.firstName)} ${capitalize(widget.currentUser.lastName)}',
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
                                    '${capitalize(employee['firstName'])} ${capitalize(employee['lastName'])}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Tooltip(
                                      message:
                                          'Add the role Certified to this employee.',
                                      child: // Certified Toggle Button
                                          GestureDetector(
                                        onTap: () => toggleField(
                                            employee['id'],
                                            'isCertified',
                                            employee['isCertified']),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: employee['isCertified']
                                                  ? Colors.green
                                                  : Colors.greenAccent,
                                              width: 2,
                                            ),
                                            color: employee['isCertified']
                                                ? Colors.green
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'C',
                                            style: TextStyle(
                                              color: employee['isCertified']
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 8), // Space between buttons

                                    // Manager Toggle Button
                                    Tooltip(
                                      message:
                                          "Give the role Manager to this employee.",
                                      child: GestureDetector(
                                        onTap: () => toggleField(employee['id'],
                                            'isManager', employee['isManager']),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: employee['isManager']
                                                  ? Colors.blue
                                                  : Colors.blueAccent,
                                              width: 2,
                                            ),
                                            color: employee['isManager']
                                                ? Colors.blue
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'M',
                                            style: TextStyle(
                                              color: employee['isManager']
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8), // Space between buttons

                                    // Admin Toggle Button (only visible for SuperAdmin)
                                    if (widget.currentUser.isSuperAdmin) ...[
                                      Tooltip(
                                        message:
                                            "Give the role Admin to this employee.",
                                        child: GestureDetector(
                                          onTap: () => toggleField(
                                              employee['id'],
                                              'isAdmin',
                                              employee['isAdmin']),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: employee['isAdmin']
                                                    ? Colors.yellow
                                                    : Colors.yellowAccent,
                                                width: 2,
                                              ),
                                              color: employee['isAdmin']
                                                  ? Colors.yellow
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'A',
                                              style: TextStyle(
                                                color: employee['isAdmin']
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    SizedBox(width: 8), // Space between buttons

                                    // Edit Button
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
                                                  'Are you sure you want to delete ${capitalize(employee['firstName'])} ${capitalize(employee['lastName'])}?'),
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
