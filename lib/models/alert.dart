import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore's Timestamp type

class Alert {
  final String senderFirstName;
  final String senderLastName;
  final String senderProfilePictureUrl;
  final Timestamp timestamp; // Keep it as Firestore's Timestamp
  final String senderDepartmentName;

  Alert({
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderProfilePictureUrl,
    required this.timestamp, // Now using Firestore's Timestamp
    required this.senderDepartmentName,
  });

  // Factory constructor to create Alert from Firestore document
  factory Alert.fromFirestore(Map<String, dynamic> data) {
    return Alert(
      senderFirstName: data['senderFirstName'] ?? '',
      senderLastName: data['senderLastName'] ?? '',
      senderProfilePictureUrl: data['senderProfilePictureUrl'] ?? '',
      timestamp: data['timestamp'] as Timestamp? ??
          Timestamp.now(), // Keep it as Firestore Timestamp
      senderDepartmentName: data['senderDepartmentName'] ?? '',
    );
  }
}
