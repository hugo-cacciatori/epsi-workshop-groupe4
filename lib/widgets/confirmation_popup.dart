import 'package:flutter/material.dart';
import 'package:alertchain/models/user.dart';

class ConfirmationPopup extends StatelessWidget {
  final List<User> certifiedEmployees;

  ConfirmationPopup({required this.certifiedEmployees});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Alert Sent Successfully!',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
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

  // Build a list of certified employees
  Widget _buildCertifiedEmployeesList() {
    return Column(
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
                    '${employee.firstName[0]}${employee.lastName[0]}',
                    style: TextStyle(color: Colors.white),
                  )
                : null,
          ),
          title: Text('${employee.firstName} ${employee.lastName}'),
        );
      }).toList(),
    );
  }
}
