class User {
  final String id;
  final String firstName;
  final String lastName;
  final String organizationID;
  final bool isAdmin;
  final bool isCertified;
  final bool isManager;
  final bool isSuperAdmin;
  final String email;
  final String phoneNumber;
  final String departmentName;
  final String profilePictureUrl; // New field for profile picture URL

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.organizationID,
    required this.isAdmin,
    required this.isCertified,
    required this.isManager,
    required this.isSuperAdmin,
    required this.email,
    required this.phoneNumber,
    required this.departmentName,
    this.profilePictureUrl = '', // Default value for profile picture URL
  });

  // Create a factory constructor to create a User instance from Firestore data
  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      organizationID: data['organizationID'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      isCertified: data['isCertified'] ?? false,
      isManager: data['isManager'] ?? false,
      isSuperAdmin: data['isSuperAdmin'] ?? false,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      departmentName: data['departmentName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ??
          '', // Extract profile picture URL from Firestore
    );
  }
}
