import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String senderID; // Add this field
  final String senderFirstName;
  final String senderLastName;
  final String senderProfilePictureUrl;
  final Timestamp timestamp;
  final String senderDepartmentName;

  Alert({
    required this.senderID, // Include this in the constructor
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderProfilePictureUrl,
    required this.timestamp,
    required this.senderDepartmentName,
  });

  // Factory constructor to create Alert from Firestore document
  factory Alert.fromFirestore(Map<String, dynamic> data) {
    return Alert(
      senderID: data['senderID'] ?? '', // Add this mapping
      senderFirstName: data['senderFirstName'] ?? '',
      senderLastName: data['senderLastName'] ?? '',
      senderProfilePictureUrl: data['senderProfilePictureUrl'] ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      senderDepartmentName: data['senderDepartmentName'] ?? '',
    );
  }
}
