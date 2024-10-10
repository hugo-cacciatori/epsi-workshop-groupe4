import 'package:alertchain/helpers/string_helper.dart';
import 'package:alertchain/models/alert.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore's Timestamp type

class AlertCard extends StatefulWidget {
  final Alert alert;

  AlertCard({required this.alert});

  @override
  _AlertCardState createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  late Timer _timer;
  late String _timeAgo;

  @override
  void initState() {
    super.initState();
    _updateTimeAgo(); // Initialize the timeAgo variable
    // Set up a timer that updates every second
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _updateTimeAgo(); // Update the time every second
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _updateTimeAgo() {
    setState(() {
      _timeAgo = calculateTimeAgo(
          widget.alert.timestamp); // Update _timeAgo every second
    });
  }

  String calculateTimeAgo(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 30) {
      return 'now'; // Return 'now' if less than 30 seconds
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago'; // Update to show seconds
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago'; // Add period
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago'; // Add period
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago'; // Add period
    } else {
      return '${difference.inDays ~/ 30} months ago'; // Add period
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.0),
      padding: EdgeInsets.all(10.0),
      constraints: BoxConstraints(maxWidth: 220), // Wider card
      decoration: BoxDecoration(
        color: Colors.orange, // Default color set to orange
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // White bubble for the avatar and "ALERT" text
          Container(
            width: double.infinity, // Take all horizontal space
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white, // White background for bubble
              borderRadius: BorderRadius.circular(20.0), // More rounded corners
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circle avatar for the sender
                buildUserAvatar(
                  lastName: widget.alert.senderLastName,
                  firstName: widget.alert.senderFirstName,
                  profilePictureUrl: widget.alert.senderProfilePictureUrl,
                ),
                Text(
                  'ALERT!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Make it easily visible
                    fontSize: 16, // Adjust font size if needed
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5), // Closer space between alert bubble and time
          SizedBox(
            height: 20,
            width: 150,
            child: Text(
              _timeAgo, // Time message
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'From ${capitalize(widget.alert.senderDepartmentName)}', // Department name with capitalization
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // Add ellipsis for long department names
                ),
              ),
              Tooltip(
                message: "Open alert details",
                child: IconButton(
                  icon: Icon(Icons.open_in_new,
                      size: 18), // Slightly bigger icon size
                  onPressed: () {
                    // Future implementation for opening alert details
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildUserAvatar({
  required String firstName,
  required String lastName,
  required String? profilePictureUrl,
}) {
  return Tooltip(
    message: '${capitalize(firstName)} ${capitalize(lastName)}',
    child: CircleAvatar(
      radius: 20, // Smaller radius for alert avatars
      backgroundImage:
          (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
              ? NetworkImage(profilePictureUrl)
              : null,
      backgroundColor: Colors.blueAccent,
      child: (profilePictureUrl == null || profilePictureUrl.isEmpty)
          ? Text(
              '${capitalize(firstName[0])}${capitalize(lastName[0])}', // Use initials
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            )
          : null,
    ),
  );
}
