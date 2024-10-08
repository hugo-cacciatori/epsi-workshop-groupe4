import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeFormPage extends StatefulWidget {
  final String organizationID;
  final Map<String, dynamic>? employee; // Optional employee data for editing
  final Function onEmployeeUpdated; // Callback function to refresh list

  EmployeeFormPage({
    required this.organizationID,
    this.employee,
    required this.onEmployeeUpdated,
  });

  @override
  _EmployeeFormPageState createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController departmentNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill the text fields with existing data
    if (widget.employee != null) {
      firstNameController.text = widget.employee!['firstName'] ?? '';
      lastNameController.text = widget.employee!['lastName'] ?? '';
      emailController.text = widget.employee!['email'] ?? '';
      phoneNumberController.text = widget.employee!['phoneNumber'] ?? '';
      departmentNameController.text = widget.employee!['departmentName'] ??
          ''; // Initialize department name
    }
  }

  Future<void> addOrUpdateEmployee() async {
    // Get the data from the controllers
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String email = emailController.text;
    String phoneNumber = phoneNumberController.text;
    String departmentName =
        departmentNameController.text; // Get department name

    try {
      if (widget.employee == null) {
        // Add new employee
        await FirebaseFirestore.instance.collection('users').add({
          'firstName': firstName,
          'lastName': lastName,
          'organizationID': widget.organizationID,
          'email': email,
          'phoneNumber': phoneNumber,
          'departmentName': departmentName, // Add department name
          'isAdmin': false,
          'isCertified': false,
          'isManager': false,
          'isSuperAdmin': false,
          // Add any additional fields as necessary
        });
      } else {
        // Edit existing employee
        String employeeId =
            widget.employee!['id']; // Use the employee's document ID

        // Check if the document exists
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('users').doc(employeeId);
        DocumentSnapshot docSnapshot = await docRef.get();
        if (!docSnapshot.exists) {
          throw Exception("Employee document not found"); // Document not found
        }

        await docRef.update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'departmentName': departmentName, // Update department name
        });
      }

      // Notify the AdminDashboardPage to refresh the employee list
      widget.onEmployeeUpdated();
      Navigator.of(context).pop(); // Close the page after saving
    } catch (e) {
      print('Error updating employee: $e'); // Log error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update employee: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: departmentNameController, // Add department name input
              decoration: InputDecoration(labelText: 'Department Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addOrUpdateEmployee, // Call the combined function
              child: Text(
                  widget.employee == null ? 'Add Employee' : 'Update Employee'),
            ),
          ],
        ),
      ),
    );
  }
}
