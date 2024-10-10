import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:alertchain/models/alert.dart';
import 'package:alertchain/helpers/string_helper.dart';
import 'package:alertchain/models/user.dart';

class AlertPopup extends StatelessWidget {
  final Alert alert;
  final User currentUser;
  final List<User> certifiedEmployees;

  AlertPopup({
    required this.alert,
    required this.currentUser,
    required this.certifiedEmployees,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the current user is the sender of the alert
    bool isSentByCurrentUser = alert.senderID == currentUser.id;

    return AlertDialog(
      title: Text(
        isSentByCurrentUser ? 'Alert Sent Successfully!' : 'ALERT!',
        style: TextStyle(
          color: isSentByCurrentUser ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        // Allows for scrolling content
        child: Column(
          // Use Column instead of ListView
          mainAxisSize:
              MainAxisSize.min, // Allow the column to take minimum height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isSentByCurrentUser
                ? _buildSentByCurrentUserContent()
                : _buildReceivedAlertContent(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }

  // Build content for when the alert was sent by the current user
  Widget _buildSentByCurrentUserContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You have successfully sent an alert to the following certified employees:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        _buildCertifiedEmployeesList(),
      ],
    );
  }

  // Build a list of certified employees
  Widget _buildCertifiedEmployeesList() {
    return Column(
      // Use Column for list of employees
      children: certifiedEmployees.map((employee) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (employee.profilePictureUrl != null &&
                    employee.profilePictureUrl!.isNotEmpty)
                ? NetworkImage(employee.profilePictureUrl!)
                : null,
            backgroundColor: Colors.blueAccent,
            child: (employee.profilePictureUrl == null ||
                    employee.profilePictureUrl!.isEmpty)
                ? Text(
                    '${capitalize(employee.firstName[0])}${capitalize(employee.lastName[0])}',
                    style: TextStyle(color: Colors.white),
                  )
                : null,
          ),
          title: Text(
              '${capitalize(employee.firstName)} ${capitalize(employee.lastName)}'),
        );
      }).toList(),
    );
  }

  // Build content for when the alert was received by the current user
  Widget _buildReceivedAlertContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'From: ${capitalize(alert.senderDepartmentName)} Department',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          'Sent by: ${capitalize(alert.senderFirstName)} ${capitalize(alert.senderLastName)}',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
        Text(
          'Time: ${calculateTimeAgo(alert.timestamp)}',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Reusing the time ago calculation method from the AlertCard
  String calculateTimeAgo(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 30) {
      return 'now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${difference.inDays ~/ 30} months ago';
    }
  }
}
