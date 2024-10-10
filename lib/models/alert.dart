import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id; // Field for unique ID
  final String senderID;
  final String senderFirstName;
  final String senderLastName;
  final String senderProfilePictureUrl;
  final Timestamp timestamp;
  final String senderDepartmentName;

  Alert({
    required this.id, // Include this in the constructor
    required this.senderID,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderProfilePictureUrl,
    required this.timestamp,
    required this.senderDepartmentName,
  });

  // Factory constructor to create Alert from Firestore document
  factory Alert.fromFirestore(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>; // Access document data directly
    return Alert(
      id: doc.id, // Retrieve the document ID directly from the DocumentSnapshot
      senderID: data['senderID'] ?? '',
      senderFirstName: data['senderFirstName'] ?? '',
      senderLastName: data['senderLastName'] ?? '',
      senderProfilePictureUrl: data['senderProfilePictureUrl'] ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      senderDepartmentName: data['senderDepartmentName'] ?? '',
    );
  }
}
